from fastapi import APIRouter

router = APIRouter()


@router.get("/")
async def read_root():
    return {
        "message": "Use /stream-text to see streaming output.",
        "learning_order": ["_01_root", "_02_stream_text", "_03_stream_llm"],
    }
