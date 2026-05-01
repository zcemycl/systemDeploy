import asyncio
import time
import uuid
from collections.abc import AsyncIterator
from typing import Any, TypedDict

from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import END, START, StateGraph
from langgraph.types import Command, interrupt

NODE_ORDER = ["a", "b", "b_review", "c", "c_review", "d", "d_review"]
REVIEW_NODES = {"b_review", "c_review", "d_review"}


def _node_label(node_id: str) -> str:
    if node_id.endswith("_review"):
        base = node_id.replace("_review", "").upper()
        return f"Step {base} Review"
    return f"Step {node_id.upper()}"


class InterruptGraphState(TypedDict):
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


class RunContext(TypedDict):
    queue: asyncio.Queue[ReviewDecision]


RUN_CONTEXTS: dict[str, RunContext] = {}


def create_interrupt_run() -> str:
    run_id = str(uuid.uuid4())
    RUN_CONTEXTS[run_id] = {"queue": asyncio.Queue()}
    return run_id


async def submit_interrupt_decision(run_id: str, decision: ReviewDecision) -> bool:
    context = RUN_CONTEXTS.get(run_id)
    if not context:
        return False
    await context["queue"].put(decision)
    return True


async def _await_review_decision(run_id: str, node_id: str) -> ReviewDecision:
    context = RUN_CONTEXTS.get(run_id)
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


def _cleanup_run(run_id: str) -> None:
    RUN_CONTEXTS.pop(run_id, None)


def get_interrupt_graph_definition() -> dict[str, list[dict[str, Any]]]:
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


async def _node_a(state: InterruptGraphState) -> InterruptGraphState:
    await asyncio.sleep(0.4)
    return {
        **state,
        "steps": [*state["steps"], "a"],
    }


async def _node_b(state: InterruptGraphState) -> InterruptGraphState:
    await asyncio.sleep(0.4)
    return {
        **state,
        "steps": [*state["steps"], "b"],
        "b_output": "B generated draft content",
    }


async def _node_c(state: InterruptGraphState) -> InterruptGraphState:
    await asyncio.sleep(0.4)
    return {
        **state,
        "steps": [*state["steps"], "c"],
        "c_output": f"C transformed: {state['b_output'] or 'empty'}",
    }


async def _node_d(state: InterruptGraphState) -> InterruptGraphState:
    await asyncio.sleep(0.4)
    return {
        **state,
        "steps": [*state["steps"], "d"],
        "d_output": f"D transformed: {state['c_output'] or 'empty'}",
    }


def _review_payload(state: InterruptGraphState, node_id: str) -> dict[str, Any]:
    review_text = ""
    if node_id == "b_review":
        review_text = state["b_output"]
    elif node_id == "c_review":
        review_text = state["c_output"]
    elif node_id == "d_review":
        review_text = state["d_output"]
    return {
        "node_id": node_id,
        "node_label": _node_label(node_id),
        "review_text": review_text,
        "allowed_actions": ["approve", "reject", "edit"],
    }


def _apply_review_decision(
    state: InterruptGraphState, node_id: str, decision: dict[str, Any]
) -> InterruptGraphState:
    next_state: InterruptGraphState = {
        **state,
        "steps": [*state["steps"], node_id],
        "review_result": {
            "action": decision.get("action"),
            "comment": decision.get("comment"),
        },
    }
    if decision.get("action") == "edit" and decision.get("edited_text"):
        if node_id == "b_review":
            next_state["b_output"] = decision["edited_text"]
        elif node_id == "c_review":
            next_state["c_output"] = decision["edited_text"]
        elif node_id == "d_review":
            next_state["d_output"] = decision["edited_text"]
    return next_state


def _node_b_review(state: InterruptGraphState) -> InterruptGraphState:
    decision = interrupt(_review_payload(state, "b_review"))
    return _apply_review_decision(state, "b_review", decision)


def _node_c_review(state: InterruptGraphState) -> InterruptGraphState:
    decision = interrupt(_review_payload(state, "c_review"))
    return _apply_review_decision(state, "c_review", decision)


def _node_d_review(state: InterruptGraphState) -> InterruptGraphState:
    decision = interrupt(_review_payload(state, "d_review"))
    return _apply_review_decision(state, "d_review", decision)


def _route_after_b_review(state: InterruptGraphState) -> str:
    action = (state.get("review_result") or {}).get("action")
    return END if action == "reject" else "c"


def _route_after_c_review(state: InterruptGraphState) -> str:
    action = (state.get("review_result") or {}).get("action")
    return END if action == "reject" else "d"


def _route_after_d_review(state: InterruptGraphState) -> str:
    _ = state
    return END


def _build_graph():
    graph = StateGraph(InterruptGraphState)
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

    return graph.compile(checkpointer=MemorySaver())


interrupt_graph = _build_graph()


async def stream_interrupt_graph_progress(run_id: str) -> AsyncIterator[dict[str, Any]]:
    if run_id not in RUN_CONTEXTS:
        yield {"type": "stream_error", "run_id": run_id, "message": "Unknown run_id"}
        return

    state: InterruptGraphState = {
        "run_id": run_id,
        "steps": [],
        "b_output": "",
        "c_output": "",
        "d_output": "",
        "review_result": None,
    }
    config = {"configurable": {"thread_id": run_id}}
    input_value: InterruptGraphState | Command = state
    node_index = 0
    node_started_at = time.perf_counter()

    yield {
        "type": "graph_init",
        "run_id": run_id,
        "graph": get_interrupt_graph_definition(),
        "state": state,
    }

    try:
        while node_index < len(NODE_ORDER):
            interrupted = False
            async for update in interrupt_graph.astream(
                input_value, config=config, stream_mode="updates"
            ):
                if "__interrupt__" in update:
                    node_id = NODE_ORDER[node_index]
                    interrupt_obj = update["__interrupt__"][0]
                    payload = interrupt_obj.value or {}
                    yield {
                        "type": "review_required",
                        "run_id": run_id,
                        "node": {
                            "id": node_id,
                            "label": _node_label(node_id),
                            "is_review": True,
                        },
                        "payload": {"review_text": payload.get("review_text", "")},
                        "allowed_actions": payload.get(
                            "allowed_actions", ["approve", "reject", "edit"]
                        ),
                    }
                    decision = await _await_review_decision(run_id, node_id)
                    yield {
                        "type": "review_submitted",
                        "run_id": run_id,
                        "node": {
                            "id": node_id,
                            "label": _node_label(node_id),
                            "is_review": True,
                        },
                        "decision": {
                            "action": decision["action"],
                            "comment": decision["comment"],
                        },
                    }
                    input_value = Command(resume=decision)
                    interrupted = True
                    break

                for updated_node_id, node_update in update.items():
                    if updated_node_id not in NODE_ORDER:
                        continue

                    state = {**state, **node_update}
                    if node_index < len(NODE_ORDER) and updated_node_id == NODE_ORDER[node_index]:
                        yield {
                            "type": "node_completed",
                            "run_id": run_id,
                            "node": {
                                "id": updated_node_id,
                                "label": _node_label(updated_node_id),
                                "is_review": updated_node_id.endswith("_review"),
                            },
                            "duration_ms": round(
                                (time.perf_counter() - node_started_at) * 1000, 2
                            ),
                            "state": state,
                        }
                        node_index += 1
                        node_started_at = time.perf_counter()

                        if (
                            updated_node_id in REVIEW_NODES
                            and (state["review_result"] or {}).get("action") == "reject"
                        ):
                            yield {
                                "type": "graph_completed",
                                "run_id": run_id,
                                "state": state,
                                "stopped_reason": f"rejected_at_{updated_node_id}",
                            }
                            return

            if interrupted:
                continue
            break

        yield {"type": "graph_completed", "run_id": run_id, "state": state}
    finally:
        _cleanup_run(run_id)
