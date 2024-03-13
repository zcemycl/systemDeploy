from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from simple_auth import dummy

from .core.routers import auth
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
