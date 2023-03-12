from fastapi import Request, FastAPI 
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()

@app.get("/")
async def home():
    return {"message": "Hello world!"}

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