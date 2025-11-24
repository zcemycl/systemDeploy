import asyncio
from concurrent import futures

import grpc
from app.grpc.generated import data_pb2_grpc
from app.grpc.services import DataServiceServicer

# from app.grpc.generated import member_pb2_grpc
# from app.grpc.services import MemberService



def register_services(server: grpc.Server):
    # member_pb2_grpc.add_MemberServiceServicer_to_server(MemberService(), server)
    data_pb2_grpc.add_DataServiceServicer_to_server(DataServiceServicer(), server)

async def serve():
    server = grpc.aio.server()
    # server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    register_services(server)
    server.add_insecure_port("[::]:50051")
    await server.start()
    await server.wait_for_termination()

if __name__ == "__main__":
    asyncio.run(serve())
