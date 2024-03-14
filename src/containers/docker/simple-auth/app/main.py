from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from loguru import logger
from simple_auth import dummy
from simple_auth.dataclasses import users
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql import select

from .core.routers import auth
from .database import get_async_session
from .settings import Settings

settings = Settings()
print(settings)
app = FastAPI()
app.include_router(auth.router)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:4555",  # local dev
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



@app.get("/")
async def read_root():
    return {"Hello": "World", "key": settings.jwt_secret_key}


@app.get("/dummy")
async def read_dummy():
    return dummy()

@app.get("/users/count")
async def count(
    session: AsyncSession = Depends(get_async_session),
):
    stmt = select(users)
    res = (await session.execute(stmt)).scalars().all()
    jsons = [tmp.as_dict() for tmp in res]
    logger.info(jsons)
    return jsons
