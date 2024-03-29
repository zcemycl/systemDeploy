from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from loguru import logger

from .core.auth import OAuthBearer
from .settings import get_settings

settings = get_settings()
app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",  # local dev
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def read_root():
    return {"Hello": "World"}


@app.get("/protected", tags=["protected"], dependencies=[Depends(OAuthBearer())])
async def read_protected():
    return {"Hello": "Protected"}
