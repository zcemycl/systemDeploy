from fastapi import FastAPI
from routes._01_root import router as root_router
from routes._02_stream_text import router as stream_text_router
from routes._03_stream_llm import router as stream_llm_router

app = FastAPI()

app.include_router(root_router)
app.include_router(stream_text_router)
app.include_router(stream_llm_router)
