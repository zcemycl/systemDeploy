import time

from fastapi import HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

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
    username = payload.get("sub")
    expire = payload.get("exp")
    if username is None:
        raise credentials_exception
    if expire is None:
        raise credentials_exception
    if expire >= time.time():
        raise credentials_exception
    return payload


class JWTBearer(HTTPBearer):
    def __init__(self, auto_error: bool = True):
        super(JWTBearer, self).__init__(auto_error=auto_error)

    async def __call__(self, request: Request):
        credentials: HTTPAuthorizationCredentials = await super(JWTBearer, self).__call__(request)
        if credentials is None:
            return credentials
        if credentials.scheme.lower() != "bearer":
            raise HTTPException(status_code=403, detail="Invalid authentication scheme.")
        jwt_token = credentials.credentials
        try:
            payload = decode_jwt(jwt_token)
        except credentials_exception:
            payload = None
        if payload is None:
            raise HTTPException(status_code=403, detail="Invalid token or expired token.")

        return credentials.credentials
