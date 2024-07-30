from fastapi import Depends, FastAPI

app = FastAPI()

@app.get(
    "/"
)
async def read_home():
    return {"Hello": "World"}
