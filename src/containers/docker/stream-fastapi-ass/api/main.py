from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes._01_root import router as root_router
from routes._02_stream_text import router as stream_text_router
from routes._03_stream_llm import router as stream_llm_router
from routes._04_stream_graph import router as stream_graph_router
from routes._05_stream_spawn import router as stream_spawn_router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(root_router)
app.include_router(stream_text_router)
app.include_router(stream_llm_router)
app.include_router(stream_graph_router)
app.include_router(stream_spawn_router)
