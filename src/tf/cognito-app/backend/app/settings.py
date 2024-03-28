from typing import List

from pydantic import BaseModel
from pydantic_settings import BaseSettings, SettingsConfigDict


class Jwk(BaseModel):
    alg: str
    e: str
    kid: str
    kty: str
    n: str
    use: str

class Jwks(BaseModel):
    keys: List[Jwk]

class AwsCognito(BaseModel):
    authorization_endpoint: str
    end_session_endpoint: str
    id_token_signing_alg_values_supported: List[str]
    issuer: str
    jwks_uri: str
    response_types_supported: List[str]
    revocation_endpoint: str
    scopes_supported: List[str]
    subject_types_supported: List[str]
    token_endpoint: str
    token_endpoint_auth_methods_supported: List[str]
    userinfo_endpoint: str

class Settings(BaseSettings):
    openid_conf_uri: str
    model_config = SettingsConfigDict(env_file=('.env', '.env.prod'))
