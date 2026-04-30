import asyncio
import time
from collections.abc import AsyncIterator
from typing import Any, TypedDict

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
    b_results: list[BResult]
    d_inputs: list[BResult]
    d_results: list[DResult]
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


async def _run_b_item(item: SpawnItem, fail_ids: set[int]) -> BResult:
    await asyncio.sleep(0.15)
    return {"id": item["id"], "value": item["value"], "passed": item["id"] not in fail_ids}


async def _step_b_spawn(state: SpawnAgentState) -> list[BResult]:
    fail_ids = set(state["fail_ids"])
    tasks = [_run_b_item(item, fail_ids) for item in state["items"]]
    return await asyncio.gather(*tasks)


async def _step_c(state: SpawnAgentState) -> None:
    await asyncio.sleep(0.2)


async def _run_d_item(item: BResult) -> DResult:
    await asyncio.sleep(0.12)
    return {"id": item["id"], "value": item["value"], "d_output": f"{item['value']}-processed-by-d"}


async def _step_d_spawn(state: SpawnAgentState) -> list[DResult]:
    tasks = [_run_d_item(item) for item in state["d_inputs"]]
    return await asyncio.gather(*tasks)


async def _step_e(state: SpawnAgentState) -> None:
    await asyncio.sleep(0.2)


async def stream_spawn_agent_progress(
    input_count: int,
    fail_ids: list[int],
) -> AsyncIterator[dict[str, Any]]:
    state = _build_initial_state(input_count=input_count, fail_ids=fail_ids)
    graph = get_spawn_graph_definition()

    yield {"type": "graph_init", "graph": graph, "state": state}

    started = time.perf_counter()
    yield {"type": "node_started", "node": {"id": "a", "label": "Step A"}, "state": state}
    await _step_a(state)
    yield {
        "type": "node_completed",
        "node": {"id": "a", "label": "Step A"},
        "duration_ms": round((time.perf_counter() - started) * 1000, 2),
        "state": state,
    }

    started = time.perf_counter()
    yield {
        "type": "node_started",
        "node": {"id": "b", "label": "Step B"},
        "state": state,
        "spawn_total": len(state["items"]),
    }
    b_results = await _step_b_spawn(state)
    state["b_results"] = b_results
    state["summary"]["b_passed"] = len([item for item in b_results if item["passed"]])
    state["summary"]["b_failed"] = len([item for item in b_results if not item["passed"]])
    for item in b_results:
        yield {
            "type": "spawn_item",
            "node_id": "b",
            "item": item,
        }
    yield {
        "type": "node_completed",
        "node": {"id": "b", "label": "Step B"},
        "duration_ms": round((time.perf_counter() - started) * 1000, 2),
        "state": state,
    }

    state["d_inputs"] = [item for item in state["b_results"] if item["passed"]]

    started = time.perf_counter()
    yield {"type": "node_started", "node": {"id": "c", "label": "Step C"}, "state": state}
    await _step_c(state)
    yield {
        "type": "node_completed",
        "node": {"id": "c", "label": "Step C"},
        "duration_ms": round((time.perf_counter() - started) * 1000, 2),
        "state": state,
    }

    started = time.perf_counter()
    yield {
        "type": "node_started",
        "node": {"id": "d", "label": "Step D"},
        "state": state,
        "spawn_total": len(state["d_inputs"]),
    }
    d_results = await _step_d_spawn(state)
    state["d_results"] = d_results
    state["summary"]["d_processed"] = len(d_results)
    for item in d_results:
        yield {"type": "spawn_item", "node_id": "d", "item": item}
    yield {
        "type": "node_completed",
        "node": {"id": "d", "label": "Step D"},
        "duration_ms": round((time.perf_counter() - started) * 1000, 2),
        "state": state,
    }

    started = time.perf_counter()
    yield {"type": "node_started", "node": {"id": "e", "label": "Step E"}, "state": state}
    await _step_e(state)
    yield {
        "type": "node_completed",
        "node": {"id": "e", "label": "Step E"},
        "duration_ms": round((time.perf_counter() - started) * 1000, 2),
        "state": state,
    }

    yield {"type": "graph_completed", "state": state}
