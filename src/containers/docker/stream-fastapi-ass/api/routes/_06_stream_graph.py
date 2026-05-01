import json

from agents._06_review_graph_agent import (create_review_run,
                                           get_review_graph_definition,
                                           stream_review_graph_progress,
                                           submit_review_decision)
from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

router = APIRouter()


class ReviewDecisionRequest(BaseModel):
    run_id: str
    node_id: str = Field(pattern="^(b_review|c_review|d_review)$")
    action: str = Field(pattern="^(approve|reject|edit)$")
    edited_text: str | None = None
    comment: str | None = None


@router.get("/stream-graph-06")
async def stream_graph_06():
    run_id = create_review_run()

    async def event_stream():
        try:
            async for event in stream_review_graph_progress(run_id=run_id):
                yield f"data: {json.dumps(event)}\n\n"
        except Exception as exc:
            yield (
                f"data: {json.dumps({'type': 'stream_error', 'run_id': run_id, 'message': str(exc)})}\n\n"
            )
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


@router.post("/stream-graph-06/review-decision")
async def stream_graph_06_review_decision(payload: ReviewDecisionRequest):
    accepted = await submit_review_decision(
        run_id=payload.run_id,
        decision={
            "node_id": payload.node_id,
            "action": payload.action,
            "edited_text": payload.edited_text,
            "comment": payload.comment,
        },
    )
    if not accepted:
        raise HTTPException(status_code=404, detail="run_id not found or already completed")
    return {"ok": True}
