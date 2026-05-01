import json

from agents._04_dummy_agent import (get_dummy_graph_definition,
                                    stream_dummy_agent_progress)
from fastapi import APIRouter
from fastapi.responses import StreamingResponse

router = APIRouter()


@router.get("/stream-graph")
async def stream_graph():
    async def event_stream():
        async for event in stream_dummy_agent_progress():
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


@router.get("/stream-graph/definition")
async def stream_graph_definition():
    return get_dummy_graph_definition()
