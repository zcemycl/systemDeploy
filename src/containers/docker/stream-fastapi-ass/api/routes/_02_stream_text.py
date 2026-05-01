import asyncio

from fastapi import APIRouter
from fastapi.responses import StreamingResponse

router = APIRouter()


def generate_long_text() -> str:
    paragraph = (
        "Streaming text with FastAPI lets clients render output as it arrives, "
        "instead of waiting for the full payload. "
    )
    return "\n".join(f"{i:03d}: {paragraph}" for i in range(1, 151))


@router.get("/stream-text")
async def stream_text():
    async def event_stream():
        long_text = generate_long_text()

        for line in long_text.splitlines():
            yield line + "\n"
            await asyncio.sleep(0.03)

    return StreamingResponse(event_stream(), media_type="text/plain")
