from fastapi import APIRouter

from ...settings import Settings

settings = Settings()
router = APIRouter(
    prefix="/auth",
    tags=["auth"],
)

@router.get("/", tags=["auth"])
async def root():
    return {"Hello": "Auth", "key": settings.jwt_secret_key}
