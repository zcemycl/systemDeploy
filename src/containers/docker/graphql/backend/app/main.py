import asyncio

import grpc
from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse

from .gql import graphql_app
from .grpc.generated import data_pb2, data_pb2_grpc

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # or ["http://localhost:5173"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(graphql_app, prefix="/graphql")

async def grpc_to_bytes_get_large(query: str):
    # Create an async channel to the gRPC server
    GRPC_SERVER_URL = "localhost:50051"
    # GRPC_SERVER_URL = "grpc_server:50051"
    async with grpc.aio.insecure_channel(GRPC_SERVER_URL) as channel:
        stub = data_pb2_grpc.DataServiceStub(channel)
        req = data_pb2.DataRequest(query=query, page_size=100)
        call = stub.GetLargeDataset(req)
        async for chunk in call:
            # chunk.payload is a JSON string
            yield (chunk.payload + "\n").encode("utf-8")
            await asyncio.sleep(0)  # yield to event loop

@app.get("/stream/large")
async def stream_large(query: str = Query(default="")):
    return StreamingResponse(grpc_to_bytes_get_large(query), media_type="text/plain; charset=utf-8")
