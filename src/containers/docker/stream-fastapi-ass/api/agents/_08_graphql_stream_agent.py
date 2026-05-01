import asyncio
import time
import uuid
from collections.abc import AsyncIterator
from typing import Any, TypedDict

NODE_ORDER = ["a", "b", "c", "d"]


class RunContext(TypedDict):
    queue: asyncio.Queue[dict[str, Any]]
    done: bool


RUN_CONTEXTS: dict[str, RunContext] = {}


def get_graph_definition() -> dict[str, list[dict[str, Any]]]:
    nodes = [
        {"id": node_id, "label": f"Step {node_id.upper()}", "order": index + 1}
        for index, node_id in enumerate(NODE_ORDER)
    ]
    edges = [
        {"id": f"{source}->{target}", "source": source, "target": target}
        for source, target in zip(NODE_ORDER, NODE_ORDER[1:])
    ]
    return {"nodes": nodes, "edges": edges}


def create_run() -> str:
    run_id = str(uuid.uuid4())
    RUN_CONTEXTS[run_id] = {"queue": asyncio.Queue(), "done": False}
    return run_id


def has_run(run_id: str) -> bool:
    return run_id in RUN_CONTEXTS


async def start_run(run_id: str, prompt: str | None = None) -> bool:
    context = RUN_CONTEXTS.get(run_id)
    if context is None:
        return False
    asyncio.create_task(_produce_events(run_id=run_id, prompt=prompt))
    return True


def _cleanup_run(run_id: str) -> None:
    RUN_CONTEXTS.pop(run_id, None)


async def _produce_events(run_id: str, prompt: str | None = None) -> None:
    context = RUN_CONTEXTS.get(run_id)
    if context is None:
        return
    queue = context["queue"]

    state: dict[str, Any] = {
        "run_id": run_id,
        "prompt": prompt or "",
        "steps": [],
        "b_output": "",
        "c_output": "",
        "d_output": "",
    }
    await queue.put({"type": "graph_init", "run_id": run_id, "graph": get_graph_definition(), "state": state})

    for node_id in NODE_ORDER:
        started_at = time.perf_counter()
        await asyncio.sleep(0.5)
        state["steps"] = [*state["steps"], node_id]
        if node_id == "b":
            state["b_output"] = f"B generated from prompt: {state['prompt'] or 'default'}"
        if node_id == "c":
            state["c_output"] = f"C transformed: {state['b_output'] or 'empty'}"
        if node_id == "d":
            state["d_output"] = f"D transformed: {state['c_output'] or 'empty'}"

        await queue.put(
            {
                "type": "node_completed",
                "run_id": run_id,
                "node": {"id": node_id, "label": f"Step {node_id.upper()}"},
                "duration_ms": round((time.perf_counter() - started_at) * 1000, 2),
                "state": dict(state),
            }
        )

    await queue.put({"type": "graph_completed", "run_id": run_id, "state": state})
    context["done"] = True


async def consume_events(run_id: str) -> AsyncIterator[dict[str, Any]]:
    context = RUN_CONTEXTS.get(run_id)
    if context is None:
        yield {"type": "stream_error", "run_id": run_id, "message": "Unknown run_id"}
        return

    queue = context["queue"]
    while True:
        event = await queue.get()
        yield event
        if event.get("type") in {"graph_completed", "stream_error"}:
            _cleanup_run(run_id)
            return
