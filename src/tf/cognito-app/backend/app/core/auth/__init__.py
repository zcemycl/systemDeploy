import json

import requests
from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwk, jwt
from jose.exceptions import ExpiredSignatureError
from jose.utils import base64url_decode
from loguru import logger

from ...settings import AwsCognitoClaim, Jwk, Jwks, get_settings

settings = get_settings()

class OAuthBearer(HTTPBearer):
    def __init__(self, auto_error: bool = True):
        super(OAuthBearer, self).__init__(auto_error=auto_error)
        self.refresh_jwks()

    def refresh_jwks(self):
        resp = requests.get(settings.aws_cognito.jwks_uri)
        self.jwks = Jwks.model_validate(json.loads(resp.content))

    async def __call__(self, request: Request) -> HTTPAuthorizationCredentials:
        credentials: HTTPAuthorizationCredentials = await super(OAuthBearer, self).__call__(request)
        if credentials is None:
            return credentials

        if credentials.scheme != "Bearer":
            raise HTTPException(
                status_code=401,
                detail={
                    "error": "AUTH_INVALID_SCHEME",
                    "error_description": "Wrong authentication method, accepted methods are: [ Bearer ]",
                },
            )

        jwt_token = credentials.credentials
        split_token = jwt_token.split(".", 1)
        if len(split_token) != 2:
            raise HTTPException(
                status_code=401,
                detail={
                    "error": "AUTH_INVALID_TOKEN",
                    "error_description": "Wrong token format.",
                },
            )
        header_jwk = Jwk.model_validate(jwt.get_unverified_header(jwt_token))
        claim = AwsCognitoClaim.model_validate(jwt.get_unverified_claims(jwt_token))
        logger.info(claim)
        jwks_matched = [jwk_ for jwk_ in self.jwks.keys if jwk_.alg==header_jwk.alg and jwk_.kid==header_jwk.kid]
        if len(jwks_matched) < 1:
            raise HTTPException(
                status_code=401,
                detail={
                    "error": "AUTH_INVALID_JWK",
                    "error_description": "Wrong token format.",
                },
            )
        key = jwk.construct(jwks_matched[0].model_dump(exclude_none=True))
        try:
            user_data = jwt.decode(jwt_token, key, algorithms=[header_jwk.alg],
                audience=settings.aws_cognito.jwks_uri,
                options={"verify_exp": True})
        except ExpiredSignatureError:
             raise HTTPException(
                status_code=401,
                detail={
                    "error": "AUTH_EXPIRED",
                    "error_description": "expired token.",
                },
            )
        logger.info(user_data)
        return credentials
