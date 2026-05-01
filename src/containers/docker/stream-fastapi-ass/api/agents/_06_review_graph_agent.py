import asyncio
import time
import uuid
from collections.abc import AsyncIterator
from typing import Any, TypedDict

from langgraph.graph import END, START, StateGraph

NODE_ORDER = ["a", "b", "b_review", "c", "c_review", "d", "d_review"]
REVIEW_NODES = {"b_review", "c_review", "d_review"}


def _node_label(node_id: str) -> str:
    if node_id.endswith("_review"):
        base = node_id.replace("_review", "").upper()
        return f"Step {base} Review"
    return f"Step {node_id.upper()}"


class ReviewGraphState(TypedDict):
    run_id: str
    steps: list[str]
    b_output: str
    c_output: str
    d_output: str
    review_result: dict[str, Any] | None


class ReviewDecision(TypedDict):
    node_id: str
    action: str
    edited_text: str | None
    comment: str | None


async def _run_step(state: ReviewGraphState, node_id: str) -> ReviewGraphState:
    await asyncio.sleep(0.4)
    next_state: ReviewGraphState = {
        "steps": [*state["steps"], node_id],
        "b_output": state["b_output"],
        "c_output": state["c_output"],
        "d_output": state["d_output"],
        "review_result": state["review_result"],
    }
    if node_id == "b":
        next_state["b_output"] = "B generated draft content"
    if node_id == "c":
        next_state["c_output"] = f"C transformed: {state['b_output'] or 'empty'}"
    if node_id == "d":
        next_state["d_output"] = f"D transformed: {state['c_output'] or 'empty'}"
    return next_state


class RunContext(TypedDict):
    queue: asyncio.Queue[ReviewDecision]


def get_review_graph_definition() -> dict[str, list[dict[str, Any]]]:
    nodes = [
        {
            "id": node_id,
            "label": _node_label(node_id),
            "order": index + 1,
            "is_review": node_id.endswith("_review"),
        }
        for index, node_id in enumerate(NODE_ORDER)
    ]
    edges = [
        {"id": f"{source}->{target}", "source": source, "target": target}
        for source, target in zip(NODE_ORDER, NODE_ORDER[1:])
    ]
    return {"nodes": nodes, "edges": edges}


RUN_CONTEXTS: dict[str, RunContext] = {}


def create_review_run() -> str:
    run_id = str(uuid.uuid4())
    RUN_CONTEXTS[run_id] = {"queue": asyncio.Queue()}
    return run_id


async def submit_review_decision(run_id: str, decision: ReviewDecision) -> bool:
    context = RUN_CONTEXTS.get(run_id)
    if not context:
        return False
    await context["queue"].put(decision)
    return True


def _cleanup_run(run_id: str) -> None:
    RUN_CONTEXTS.pop(run_id, None)


async def _node_a(state: ReviewGraphState) -> ReviewGraphState:
    await asyncio.sleep(0.4)
    return {
        **state,
        "steps": [*state["steps"], "a"],
    }


async def _node_b(state: ReviewGraphState) -> ReviewGraphState:
    await asyncio.sleep(0.4)
    return {
        **state,
        "steps": [*state["steps"], "b"],
        "b_output": "B generated draft content",
    }


async def _node_c(state: ReviewGraphState) -> ReviewGraphState:
    await asyncio.sleep(0.4)
    return {
        **state,
        "steps": [*state["steps"], "c"],
        "c_output": f"C transformed: {state['b_output'] or 'empty'}",
    }


async def _node_d(state: ReviewGraphState) -> ReviewGraphState:
    await asyncio.sleep(0.4)
    return {
        **state,
        "steps": [*state["steps"], "d"],
        "d_output": f"D transformed: {state['c_output'] or 'empty'}",
    }


async def _await_review_decision(state: ReviewGraphState, node_id: str) -> ReviewDecision:
    context = RUN_CONTEXTS.get(state["run_id"])
    if context is None:
        return {
            "node_id": node_id,
            "action": "reject",
            "edited_text": None,
            "comment": "run context not found",
        }
    while True:
        decision = await context["queue"].get()
        if decision["node_id"] == node_id:
            return decision


async def _node_b_review(state: ReviewGraphState) -> ReviewGraphState:
    decision = await _await_review_decision(state, "b_review")
    next_state: ReviewGraphState = {
        **state,
        "steps": [*state["steps"], "b_review"],
        "review_result": {"action": decision["action"], "comment": decision["comment"]},
    }
    if decision["action"] == "edit" and decision["edited_text"]:
        next_state["b_output"] = decision["edited_text"]
    return next_state


async def _node_c_review(state: ReviewGraphState) -> ReviewGraphState:
    decision = await _await_review_decision(state, "c_review")
    next_state: ReviewGraphState = {
        **state,
        "steps": [*state["steps"], "c_review"],
        "review_result": {"action": decision["action"], "comment": decision["comment"]},
    }
    if decision["action"] == "edit" and decision["edited_text"]:
        next_state["c_output"] = decision["edited_text"]
    return next_state


async def _node_d_review(state: ReviewGraphState) -> ReviewGraphState:
    decision = await _await_review_decision(state, "d_review")
    next_state: ReviewGraphState = {
        **state,
        "steps": [*state["steps"], "d_review"],
        "review_result": {"action": decision["action"], "comment": decision["comment"]},
    }
    if decision["action"] == "edit" and decision["edited_text"]:
        next_state["d_output"] = decision["edited_text"]
    return next_state


def _route_after_b_review(state: ReviewGraphState) -> str:
    action = (state.get("review_result") or {}).get("action")
    return END if action == "reject" else "c"


def _route_after_c_review(state: ReviewGraphState) -> str:
    action = (state.get("review_result") or {}).get("action")
    return END if action == "reject" else "d"


def _route_after_d_review(state: ReviewGraphState) -> str:
    action = (state.get("review_result") or {}).get("action")
    return END if action == "reject" else END


def _build_graph():
    graph = StateGraph(ReviewGraphState)
    graph.add_node("a", _node_a)
    graph.add_node("b", _node_b)
    graph.add_node("b_review", _node_b_review)
    graph.add_node("c", _node_c)
    graph.add_node("c_review", _node_c_review)
    graph.add_node("d", _node_d)
    graph.add_node("d_review", _node_d_review)

    graph.add_edge(START, "a")
    graph.add_edge("a", "b")
    graph.add_edge("b", "b_review")
    graph.add_conditional_edges("b_review", _route_after_b_review, ["c", END])
    graph.add_edge("c", "c_review")
    graph.add_conditional_edges("c_review", _route_after_c_review, ["d", END])
    graph.add_edge("d", "d_review")
    graph.add_conditional_edges("d_review", _route_after_d_review, [END])

    return graph.compile()


review_graph = _build_graph()


async def stream_review_graph_progress(run_id: str) -> AsyncIterator[dict[str, Any]]:
    context = RUN_CONTEXTS.get(run_id)
    if not context:
        yield {"type": "stream_error", "run_id": run_id, "message": "Unknown run_id"}
        return

    state: ReviewGraphState = {
        "run_id": run_id,
        "steps": [],
        "b_output": "",
        "c_output": "",
        "d_output": "",
        "review_result": None,
    }
    iterator = review_graph.astream(state, stream_mode="updates")

    yield {"type": "graph_init", "run_id": run_id, "graph": get_review_graph_definition(), "state": state}

    for node_id in NODE_ORDER:
        started_at = time.perf_counter()
        if node_id in REVIEW_NODES:
            review_text = ""
            if node_id == "b_review":
                review_text = state["b_output"]
            elif node_id == "c_review":
                review_text = state["c_output"]
            elif node_id == "d_review":
                review_text = state["d_output"]

            yield {
                "type": "review_required",
                "run_id": run_id,
                "node": {"id": node_id, "label": _node_label(node_id), "is_review": True},
                "payload": {"review_text": review_text},
                "allowed_actions": ["approve", "reject", "edit"],
            }
        update = await anext(iterator)
        node_update = update.get(node_id) or {}
        state = {**state, **node_update}

        if node_id in REVIEW_NODES:
            yield {
                "type": "review_submitted",
                "run_id": run_id,
                "node": {"id": node_id, "label": _node_label(node_id), "is_review": True},
                "decision": state["review_result"],
                "state": state,
            }
            if (state["review_result"] or {}).get("action") == "reject":
                yield {
                    "type": "graph_completed",
                    "run_id": run_id,
                    "state": state,
                    "stopped_reason": f"rejected_at_{node_id}",
                }
                _cleanup_run(run_id)
                return

        yield {
            "type": "node_completed",
            "run_id": run_id,
            "node": {
                "id": node_id,
                "label": _node_label(node_id),
                "is_review": node_id.endswith("_review"),
            },
            "duration_ms": round((time.perf_counter() - started_at) * 1000, 2),
            "state": state,
        }

    yield {"type": "graph_completed", "run_id": run_id, "state": state}
    _cleanup_run(run_id)
