from fastapi import APIRouter

router = APIRouter(
    prefix="/auth",
    tags=["auth"],
)

@router.get("/", tags=["auth"])
async def root():
    return {"Hello": "Auth"}
