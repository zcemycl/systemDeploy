from fastapi import Depends, FastAPI
from loguru import logger

from .core.auth import OAuthBearer
from .settings import get_settings

settings = get_settings()
logger.info(settings)
app = FastAPI()

@app.get("/")
async def read_root():
    return {"Hello": "World"}


@app.get("/protected", tags=["protected"], dependencies=[Depends(OAuthBearer())])
async def read_protected():
    return {"Hello": "Protected"}
