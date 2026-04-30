import os

from dotenv import load_dotenv
from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import StreamingResponse
from langchain_openai import ChatOpenAI

load_dotenv()

router = APIRouter()


def get_llm() -> ChatOpenAI:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="OPENAI_API_KEY is missing. Set it in your .env file.",
        )

    return ChatOpenAI(
        model="gpt-4o-mini",
        temperature=0.2,
        api_key=api_key,
        streaming=True,
    )


@router.get("/stream-llm")
async def stream_llm(
    prompt: str = Query(default="Write a short poem about streaming APIs."),
    mode: str = Query(default="stream", pattern="^(ainvoke|stream)$"),
):
    llm = get_llm()

    if mode == "ainvoke":
        # Full response at once (no token-by-token streaming).
        result = await llm.ainvoke(prompt)
        return {"mode": "ainvoke", "content": result.content}

    async def token_stream():
        async for chunk in llm.astream(prompt):
            if chunk.content:
                # SSE format helps browsers render updates incrementally.
                yield chunk.content

    return StreamingResponse(
        token_stream(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache, no-transform",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
