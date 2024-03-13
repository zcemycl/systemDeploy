import secrets

from pydantic_settings import BaseSettings

SETTINGS = None

class Settings(BaseSettings):
    jwt_secret_key: str = secrets.token_hex(32)
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_mins: int = 30
