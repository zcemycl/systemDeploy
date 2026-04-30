from fastapi import APIRouter

router = APIRouter()


@router.get("/")
async def read_root():
    return {
        "message": "Use /stream-text to see streaming output.",
        "learning_order": ["abcd_01_root", "abcd_02_stream_text"],
    }
