import json

from agents._06_review_graph_agent import (get_review_graph_definition,
                                           stream_review_graph_progress)
from fastapi import APIRouter
from fastapi.responses import StreamingResponse

router = APIRouter()


@router.get("/stream-graph-06")
async def stream_graph_06():
    async def event_stream():
        try:
            async for event in stream_review_graph_progress():
                yield f"data: {json.dumps(event)}\n\n"
        except Exception as exc:
            yield f"data: {json.dumps({'type': 'stream_error', 'message': str(exc)})}\n\n"
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


@router.get("/stream-graph-06/definition")
async def stream_graph_06_definition():
    return get_review_graph_definition()
