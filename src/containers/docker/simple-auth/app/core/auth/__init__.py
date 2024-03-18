import time
from datetime import datetime, timedelta, timezone
from typing import Annotated, Iterator

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from simple_auth.dataclasses import post, users
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql import select

from ...database import get_async_session
from ...settings import Settings

settings = Settings()
credentials_exception = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Could not validate credentials",
    headers={"WWW-Authenticate": "Bearer"},
)

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode,
        settings.jwt_secret_key,
        algorithm=settings.jwt_algorithm)
    return encoded_jwt

def decode_jwt(token: str) -> dict:
    payload = jwt.decode(token,
        settings.jwt_secret_key,
        algorithms=[settings.jwt_algorithm])
    print(payload)
    username = payload.get("sub")
    expire = payload.get("exp")
    if username is None:
        raise credentials_exception
    if expire is None:
        raise credentials_exception
    if expire < time.time():
        raise credentials_exception
    return payload


class JWTBearer(HTTPBearer):
    def __init__(self, auto_error: bool = True):
        super(JWTBearer, self).__init__(auto_error=auto_error)

    async def __call__(self, request: Request,
        session: Iterator[AsyncSession] = Depends(get_async_session)):
        credentials: HTTPAuthorizationCredentials = await super(JWTBearer, self).__call__(request)
        print(credentials)
        if credentials is None:
            return credentials # probably wrong
        print(credentials)
        if credentials.scheme.lower() != "bearer":
            raise HTTPException(status_code=403, detail="Invalid authentication scheme.")
        jwt_token = credentials.credentials
        try:
            payload = decode_jwt(jwt_token)
        except Exception as e:
            payload = None
            print(e)
        if payload is None:
            raise HTTPException(status_code=403, detail="Invalid token or expired token.")
        stmt = select(users).where(
            users.username == payload.get("sub")
        )
        res = (await session.execute(stmt)).scalars().all()
        if len(res) == 0:
            raise HTTPException(status_code=403, detail="Invalid username.")

        return credentials.credentials, session, res[0]
