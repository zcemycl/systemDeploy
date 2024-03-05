from fastapi import Depends, FastAPI
from simple_auth import dummy

app = FastAPI()

@app.get("/")
async def read_root():
    return {"Hello": "World"}


@app.get("/dummy")
async def read_dummy():
    return dummy()
