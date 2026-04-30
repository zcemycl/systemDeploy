import asyncio
import time
from collections.abc import AsyncIterator
from typing import Any, TypedDict

from langgraph.graph import END, START, StateGraph

NODE_ORDER = ["a", "b", "b_review", "c", "c_review", "d", "d_review"]


def _node_label(node_id: str) -> str:
    if node_id.endswith("_review"):
        base = node_id.replace("_review", "").upper()
        return f"Step {base} Review"
    return f"Step {node_id.upper()}"


class ReviewGraphState(TypedDict):
    steps: list[str]


async def _run_step(state: ReviewGraphState, node_id: str) -> ReviewGraphState:
    await asyncio.sleep(0.4)
    return {"steps": [*state["steps"], node_id]}


def _make_node_runner(node_id: str):
    async def _runner(state: ReviewGraphState) -> ReviewGraphState:
        return await _run_step(state, node_id)

    return _runner


def _build_graph():
    graph = StateGraph(ReviewGraphState)
    for node_id in NODE_ORDER:
        graph.add_node(node_id, _make_node_runner(node_id))

    graph.add_edge(START, NODE_ORDER[0])
    for source, target in zip(NODE_ORDER, NODE_ORDER[1:]):
        graph.add_edge(source, target)
    graph.add_edge(NODE_ORDER[-1], END)
    return graph.compile()


review_graph = _build_graph()


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


async def stream_review_graph_progress() -> AsyncIterator[dict[str, Any]]:
    state: ReviewGraphState = {"steps": []}
    iterator = review_graph.astream(state, stream_mode="updates")

    yield {"type": "graph_init", "graph": get_review_graph_definition(), "state": state}

    for _ in NODE_ORDER:
        started_at = time.perf_counter()
        update = await anext(iterator)
        completed_node = next(iter(update))
        node_update = update[completed_node]
        state = {"steps": [*node_update.get("steps", state["steps"])]}

        yield {
            "type": "node_completed",
            "node": {
                "id": completed_node,
                "label": _node_label(completed_node),
                "is_review": completed_node.endswith("_review"),
            },
            "duration_ms": round((time.perf_counter() - started_at) * 1000, 2),
            "state": state,
        }

    yield {"type": "graph_completed", "state": state}
