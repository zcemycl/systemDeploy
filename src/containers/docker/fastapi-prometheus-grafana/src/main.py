import time
import random
from fastapi import Request, FastAPI 
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()

@app.get("/")
async def home():
    return {"message": "Hello world!"}

@app.get("/get_random")
async def get_random():
    nseconds = random.randint(0,10)
    time.sleep(nseconds)
    return {"message": f"{nseconds}"}

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

Instrumentator().instrument(app).expose(app)

if __name__ == "__main__":
    uvicorn.run(app, port=8888)