import asyncio
import operator
import time
from collections.abc import AsyncIterator
from typing import Annotated, Any, TypedDict

from langgraph.graph import END, START, StateGraph
from langgraph.types import Send

NODE_ORDER = ["a", "b", "c", "d", "e"]
SPAWN_NODES = {"b", "d"}


class SpawnItem(TypedDict):
    id: int
    value: str


class BResult(TypedDict):
    id: int
    value: str
    passed: bool


class DResult(TypedDict):
    id: int
    value: str
    d_output: str


class SpawnAgentState(TypedDict):
    input_count: int
    fail_ids: list[int]
    items: list[SpawnItem]
    b_results: Annotated[list[BResult], operator.add]
    d_inputs: list[BResult]
    d_results: Annotated[list[DResult], operator.add]
    summary: dict[str, int]


def get_spawn_graph_definition() -> dict[str, list[dict[str, Any]]]:
    nodes = [
        {
            "id": node_id,
            "label": f"Step {node_id.upper()}",
            "order": index + 1,
            "is_spawn": node_id in SPAWN_NODES,
        }
        for index, node_id in enumerate(NODE_ORDER)
    ]
    edges = [
        {"id": f"{source}->{target}", "source": source, "target": target}
        for source, target in zip(NODE_ORDER, NODE_ORDER[1:])
    ]
    return {"nodes": nodes, "edges": edges}


def _build_initial_state(input_count: int, fail_ids: list[int]) -> SpawnAgentState:
    items: list[SpawnItem] = [
        {"id": i, "value": f"input-{i}"}
        for i in range(1, input_count + 1)
    ]
    return {
        "input_count": input_count,
        "fail_ids": sorted(list(set(fail_ids))),
        "items": items,
        "b_results": [],
        "d_inputs": [],
        "d_results": [],
        "summary": {"total": input_count, "b_passed": 0, "b_failed": 0, "d_processed": 0},
    }


async def _step_a(state: SpawnAgentState) -> None:
    await asyncio.sleep(0.2)


async def _node_a(state: SpawnAgentState) -> dict[str, Any]:
    await _step_a(state)
    return {}


async def _run_b_item(item: SpawnItem, fail_ids: set[int]) -> BResult:
    await asyncio.sleep(0.15)
    return {"id": item["id"], "value": item["value"], "passed": item["id"] not in fail_ids}


async def _node_b_dispatch(state: SpawnAgentState) -> dict[str, Any]:
    await asyncio.sleep(0)
    return {}


def _route_b_spawn(state: SpawnAgentState) -> list[Send] | str:
    if not state["items"]:
        return "b_finalize"
    return [
        Send(
            "b_worker",
            {
                "b_item": item,
                "fail_ids": state["fail_ids"],
            },
        )
        for item in state["items"]
    ]


async def _node_b_worker(state: dict[str, Any]) -> dict[str, Any]:
    item = state["b_item"]
    fail_ids = set(state["fail_ids"])
    result = await _run_b_item(item, fail_ids)
    return {"b_results": [result]}


async def _node_b_finalize(state: SpawnAgentState) -> dict[str, Any]:
    b_results = state["b_results"]
    d_inputs = [item for item in b_results if item["passed"]]
    summary = {
        **state["summary"],
        "b_passed": len([item for item in b_results if item["passed"]]),
        "b_failed": len([item for item in b_results if not item["passed"]]),
    }
    return {"d_inputs": d_inputs, "summary": summary}


async def _step_c(state: SpawnAgentState) -> None:
    await asyncio.sleep(0.2)


async def _node_c(state: SpawnAgentState) -> dict[str, Any]:
    await _step_c(state)
    return {}


async def _run_d_item(item: BResult) -> DResult:
    await asyncio.sleep(0.12)
    return {"id": item["id"], "value": item["value"], "d_output": f"{item['value']}-processed-by-d"}


async def _node_d_dispatch(state: SpawnAgentState) -> dict[str, Any]:
    await asyncio.sleep(0)
    return {}


def _route_d_spawn(state: SpawnAgentState) -> list[Send] | str:
    if not state["d_inputs"]:
        return "d_finalize"
    return [
        Send(
            "d_worker",
            {
                "d_item": item,
            },
        )
        for item in state["d_inputs"]
    ]


async def _node_d_worker(state: dict[str, Any]) -> dict[str, Any]:
    result = await _run_d_item(state["d_item"])
    return {"d_results": [result]}


async def _node_d_finalize(state: SpawnAgentState) -> dict[str, Any]:
    d_results = state["d_results"]
    summary = {
        **state["summary"],
        "d_processed": len(d_results),
    }
    return {"summary": summary}


async def _step_e(state: SpawnAgentState) -> None:
    await asyncio.sleep(0.2)


async def _node_e(state: SpawnAgentState) -> dict[str, Any]:
    await _step_e(state)
    return {}


def _build_graph():
    graph = StateGraph(SpawnAgentState)
    graph.add_node("a", _node_a)
    graph.add_node("b_dispatch", _node_b_dispatch)
    graph.add_node("b_worker", _node_b_worker)
    graph.add_node("b_finalize", _node_b_finalize)
    graph.add_node("c", _node_c)
    graph.add_node("d_dispatch", _node_d_dispatch)
    graph.add_node("d_worker", _node_d_worker)
    graph.add_node("d_finalize", _node_d_finalize)
    graph.add_node("e", _node_e)

    graph.add_edge(START, "a")
    graph.add_edge("a", "b_dispatch")
    graph.add_conditional_edges(
        "b_dispatch",
        _route_b_spawn,
        ["b_worker", "b_finalize"],
    )
    graph.add_edge("b_worker", "b_finalize")
    graph.add_edge("b_finalize", "c")
    graph.add_edge("c", "d_dispatch")
    graph.add_conditional_edges(
        "d_dispatch",
        _route_d_spawn,
        ["d_worker", "d_finalize"],
    )
    graph.add_edge("d_worker", "d_finalize")
    graph.add_edge("d_finalize", "e")
    graph.add_edge("e", END)

    return graph.compile()


spawn_agent_graph = _build_graph()


async def stream_spawn_agent_progress(
    input_count: int,
    fail_ids: list[int],
) -> AsyncIterator[dict[str, Any]]:
    state = _build_initial_state(input_count=input_count, fail_ids=fail_ids)
    graph = get_spawn_graph_definition()
    iterator = spawn_agent_graph.astream(state, stream_mode="updates")

    yield {"type": "graph_init", "graph": graph, "state": state}

    stage_started_at: dict[str, float] = {}
    b_started_emitted = False
    d_started_emitted = False
    c_started_emitted = False
    e_started_emitted = False

    async for update in iterator:
        for node_name, node_update in update.items():
            node_update = node_update or {}

            if "b_results" in node_update:
                state["b_results"] = [*state["b_results"], *node_update["b_results"]]
            if "d_results" in node_update:
                state["d_results"] = [*state["d_results"], *node_update["d_results"]]
            for key in ("d_inputs", "summary"):
                if key in node_update:
                    state[key] = node_update[key]

            if node_name == "a":
                stage_started_at["a"] = stage_started_at.get("a", time.perf_counter())
                yield {"type": "node_started", "node": {"id": "a", "label": "Step A"}, "state": state}
                yield {
                    "type": "node_completed",
                    "node": {"id": "a", "label": "Step A"},
                    "duration_ms": round((time.perf_counter() - stage_started_at["a"]) * 1000, 2),
                    "state": state,
                }
                continue

            if node_name == "b_dispatch":
                stage_started_at["b"] = time.perf_counter()
                b_started_emitted = True
                yield {
                    "type": "node_started",
                    "node": {"id": "b", "label": "Step B"},
                    "state": state,
                    "spawn_total": len(state["items"]),
                }
                continue

            if node_name == "b_worker":
                for item in node_update.get("b_results", []):
                    yield {"type": "spawn_item", "node_id": "b", "item": item}
                continue

            if node_name == "b_finalize":
                if not b_started_emitted:
                    stage_started_at["b"] = time.perf_counter()
                    yield {
                        "type": "node_started",
                        "node": {"id": "b", "label": "Step B"},
                        "state": state,
                        "spawn_total": len(state["items"]),
                    }
                yield {
                    "type": "node_completed",
                    "node": {"id": "b", "label": "Step B"},
                    "duration_ms": round((time.perf_counter() - stage_started_at["b"]) * 1000, 2),
                    "state": state,
                }
                continue

            if node_name == "c":
                stage_started_at["c"] = stage_started_at.get("c", time.perf_counter())
                if not c_started_emitted:
                    c_started_emitted = True
                    yield {"type": "node_started", "node": {"id": "c", "label": "Step C"}, "state": state}
                yield {
                    "type": "node_completed",
                    "node": {"id": "c", "label": "Step C"},
                    "duration_ms": round((time.perf_counter() - stage_started_at["c"]) * 1000, 2),
                    "state": state,
                }
                continue

            if node_name == "d_dispatch":
                stage_started_at["d"] = time.perf_counter()
                d_started_emitted = True
                yield {
                    "type": "node_started",
                    "node": {"id": "d", "label": "Step D"},
                    "state": state,
                    "spawn_total": len(state["d_inputs"]),
                }
                continue

            if node_name == "d_worker":
                for item in node_update.get("d_results", []):
                    yield {"type": "spawn_item", "node_id": "d", "item": item}
                continue

            if node_name == "d_finalize":
                if not d_started_emitted:
                    stage_started_at["d"] = time.perf_counter()
                    yield {
                        "type": "node_started",
                        "node": {"id": "d", "label": "Step D"},
                        "state": state,
                        "spawn_total": len(state["d_inputs"]),
                    }
                yield {
                    "type": "node_completed",
                    "node": {"id": "d", "label": "Step D"},
                    "duration_ms": round((time.perf_counter() - stage_started_at["d"]) * 1000, 2),
                    "state": state,
                }
                continue

            if node_name == "e":
                stage_started_at["e"] = stage_started_at.get("e", time.perf_counter())
                if not e_started_emitted:
                    e_started_emitted = True
                    yield {"type": "node_started", "node": {"id": "e", "label": "Step E"}, "state": state}
                yield {
                    "type": "node_completed",
                    "node": {"id": "e", "label": "Step E"},
                    "duration_ms": round((time.perf_counter() - stage_started_at["e"]) * 1000, 2),
                    "state": state,
                }
                continue

    yield {"type": "graph_completed", "state": state}
