from fastapi import FastAPI
from loguru import logger

from .settings import get_settings

settings = get_settings()
logger.info(settings)
app = FastAPI()

@app.get("/")
async def read_root():
    return {"Hello": "World"}
