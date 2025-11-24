import asyncio
import json

from ..generated import data_pb2, data_pb2_grpc

# Ensure proto Python modules are importable: place generated files next to this script.

class DataServiceServicer(data_pb2_grpc.DataServiceServicer):
    async def GetLargeDataset(self, request, context):
        data = [4,5,6]
        for row in data:
            payload = json.dumps({"id": row, "category": "large", "value": row})
            yield data_pb2.DataChunk(payload=payload)
            # allow cancellation/backpressure
            await asyncio.sleep(0)

    async def GetAnotherDataset(self, request, context):
        data = [1,2,3]
        for row in data:
            payload = json.dumps({"id": row, "category": "other", "value": row})
            yield data_pb2.DataChunk(payload=payload)
            await asyncio.sleep(0)
