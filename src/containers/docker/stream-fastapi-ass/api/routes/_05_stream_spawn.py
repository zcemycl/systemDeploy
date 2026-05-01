import json

from agents._05_spawn_agent import (get_spawn_graph_definition,
                                    stream_spawn_agent_progress)
from fastapi import APIRouter, Query
from fastapi.responses import StreamingResponse

router = APIRouter()


def _parse_fail_ids(raw_fail_ids: str) -> list[int]:
    if not raw_fail_ids.strip():
        return []
    values = []
    for token in raw_fail_ids.split(","):
        token = token.strip()
        if token:
            values.append(int(token))
    return values


@router.get("/stream-spawn")
async def stream_spawn(
    input_count: int = Query(default=5, ge=1, le=100),
    fail_ids: str = Query(default="5"),
):
    parsed_fail_ids = _parse_fail_ids(fail_ids)

    async def event_stream():
        async for event in stream_spawn_agent_progress(
            input_count=input_count,
            fail_ids=parsed_fail_ids,
        ):
            yield f"data: {json.dumps(event)}\n\n"
        yield "data: [DONE]\n\n"

    return StreamingResponse(
        event_stream(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache, no-transform",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.get("/stream-spawn/definition")
async def stream_spawn_definition():
    return get_spawn_graph_definition()
