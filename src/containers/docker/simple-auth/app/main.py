from datetime import datetime, timedelta, timezone
from typing import Annotated, Iterator, Tuple

from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from loguru import logger
from passlib.context import CryptContext
from simple_auth import dummy
from simple_auth.dataclasses import post, users
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql import select

from .core.auth import JWTBearer, create_access_token, decode_jwt
from .core.models.user import Token
from .core.routers import auth
from .database import get_async_session
from .settings import Settings

settings = Settings()
logger.info(settings)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
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

@app.post("/user/signup", tags=["user"])
async def create_user(
    username: str,
    password: str,
    session: AsyncSession = Depends(get_async_session),
) -> Token:
    stmt = (
        select(users).where(
            users.username == username
        )
    )
    res = (await session.execute(stmt)).scalars().all()
    if len(res) > 0:
        raise HTTPException(status_code=409, detail="User already existed.")
    hashed_pwd = pwd_context.hash(password)
    session.add(
        users(username=username, hashed_pwd=hashed_pwd)
    )
    await session.commit()

    access_token_expires = timedelta(minutes=settings.jwt_access_token_expire_mins)
    access_token = create_access_token(
        data={"sub": username}, expires_delta=access_token_expires
    )
    return Token(access_token=access_token, token_type="bearer")

@app.post("/user/login", tags=["user"])
async def user_login(
    username: str,
    password: str,
    session: AsyncSession = Depends(get_async_session),
) -> Token:
    stmt = (
        select(users).where(
            users.username == username
        )
    )
    res = (await session.execute(stmt)).scalar()
    if res is None:
        raise HTTPException(status_code=401, detail="Invalid Username.")
    logger.info(res.username)
    if not pwd_context.verify(password, res.hashed_pwd):
        raise HTTPException(status_code=401, detail="Invalid Password Or Username.")
    access_token_expires = timedelta(minutes=settings.jwt_access_token_expire_mins)
    access_token = create_access_token(
        data={"sub": username}, expires_delta=access_token_expires
    )
    return Token(access_token=access_token, token_type="bearer")


@app.get("/user/count", tags=["user"])
async def count(
    session: AsyncSession = Depends(get_async_session),
):
    stmt = select(users)
    res = (await session.execute(stmt)).scalars().all()
    jsons = [tmp.as_dict() for tmp in res]
    logger.info(jsons)
    return jsons

@app.post("/user/posts", tags=["user"])
async def add_post(title: str,
    cred_db: Tuple[HTTPAuthorizationCredentials, Iterator[AsyncSession], users] = Depends(JWTBearer())):
    credentials, session, current_user_dc = cred_db
    post_dc = post(title=title, user=current_user_dc.id)
    session.add(post_dc)
    await session.commit()
    logger.info(credentials)
