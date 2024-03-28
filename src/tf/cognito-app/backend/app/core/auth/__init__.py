from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from ...settings import get_settings

settings = get_settings()

class OAuthBearer(HTTPBearer):
    def __init__(self, auto_error: bool = True):
        super(OAuthBearer, self).__init__(auto_error=auto_error)

    async def __call__(self, request: Request):
        credentials: HTTPAuthorizationCredentials = await super(OAuthBearer, self).__call__(request)
        print(credentials)
        if credentials is None:
            return credentials
