import time
import random
from fastapi import Request, FastAPI 
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import Histogram, Counter

app = FastAPI()

REQUEST_DURATION = Histogram(
    "myapp_request_duration_seconds",
    "Request duration in seconds",
    ["method", "endpoint", "status_code"],
)

RANDOM_NUMBER_DURATION = Histogram(
    "myapp_random_number_duration_seconds",
    "Duration of /get_random endpoint in seconds",
    buckets=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
)

RANDOM_NUMBER_COUNT = Counter(
    "myapp_random_number_count",
    "Count of different random number durations",
    ["nseconds"],
)

@app.get("/")
async def home():
    return {"message": "Hello world!"}

@app.get("/get_random")
async def get_random():
    with RANDOM_NUMBER_DURATION.time():
        nseconds = random.randint(0,10)
        time.sleep(nseconds)
        RANDOM_NUMBER_COUNT.labels(nseconds=str(nseconds)).inc()
        return {"message": f"{nseconds}"}

@app.middleware("http")
async def record_request_metrics(request: Request, call_next):
    if request.url.path == "/get_random":
        return await call_next(request)

    start_time = time.time()
    response = await call_next(request)
    end_time = time.time()
    duration = end_time - start_time
    REQUEST_DURATION.labels(
        method=request.method,
        endpoint=request.url.path,
        status_code=response.status_code,
    ).observe(duration)
    return response

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