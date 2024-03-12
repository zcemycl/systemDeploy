from fastapi import Depends, FastAPI
from simple_auth import dummy

from .core.routers import auth

app = FastAPI()
app.include_router(auth.router)

@app.get("/")
async def read_root():
    return {"Hello": "World"}


@app.get("/dummy")
async def read_dummy():
    return dummy()
