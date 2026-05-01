import asyncio
import time
from collections.abc import AsyncIterator
from typing import Any, TypedDict

from langgraph.graph import END, START, StateGraph

NODE_ORDER = ["a", "b", "c", "d"]


def _node_label(node_id: str) -> str:
    return f"Step {node_id.upper()}"


class DummyAgentState(TypedDict):
    steps: list[str]


async def _step_a(state: DummyAgentState) -> DummyAgentState:
    await asyncio.sleep(0.5)
    return {"steps": [*state["steps"], "a"]}


async def _step_b(state: DummyAgentState) -> DummyAgentState:
    await asyncio.sleep(0.5)
    return {"steps": [*state["steps"], "b"]}


async def _step_c(state: DummyAgentState) -> DummyAgentState:
    await asyncio.sleep(0.5)
    return {"steps": [*state["steps"], "c"]}


async def _step_d(state: DummyAgentState) -> DummyAgentState:
    await asyncio.sleep(0.5)
    return {"steps": [*state["steps"], "d"]}


def _build_graph():
    graph = StateGraph(DummyAgentState)
    graph.add_node("a", _step_a)
    graph.add_node("b", _step_b)
    graph.add_node("c", _step_c)
    graph.add_node("d", _step_d)
    graph.add_edge(START, "a")
    graph.add_edge("a", "b")
    graph.add_edge("b", "c")
    graph.add_edge("c", "d")
    graph.add_edge("d", END)
    return graph.compile()


dummy_agent_graph = _build_graph()


def get_dummy_graph_definition() -> dict[str, list[dict[str, Any]]]:
    nodes = [
        {"id": node_id, "label": _node_label(node_id), "order": index + 1}
        for index, node_id in enumerate(NODE_ORDER)
    ]
    edges = [
        {"id": f"{source}->{target}", "source": source, "target": target}
        for source, target in zip(NODE_ORDER, NODE_ORDER[1:])
    ]
    return {"nodes": nodes, "edges": edges}


async def run_dummy_agent() -> DummyAgentState:
    """Run a simple a->b->c->d graph with sleep-based dummy steps."""
    return await dummy_agent_graph.ainvoke({"steps": []})


async def stream_dummy_agent_progress() -> AsyncIterator[dict[str, Any]]:
    """
    Stream node progress events from the dummy graph in a React-friendly format.
    """
    state: DummyAgentState = {"steps": []}
    iterator = dummy_agent_graph.astream(state, stream_mode="updates")

    yield {"type": "graph_init", "graph": get_dummy_graph_definition(), "state": state}

    for _ in NODE_ORDER:
        started_at = time.perf_counter()
        update = await anext(iterator)
        completed_node = next(iter(update))
        node_update = update[completed_node]
        state = {"steps": [*node_update.get("steps", state["steps"])]}

        yield {
            "type": "node_completed",
            "node": {"id": completed_node, "label": _node_label(completed_node)},
            "duration_ms": round((time.perf_counter() - started_at) * 1000, 2),
            "state": state,
        }

    yield {"type": "graph_completed", "state": state}
