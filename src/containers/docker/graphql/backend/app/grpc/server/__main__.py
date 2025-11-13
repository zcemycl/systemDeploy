from concurrent import futures

import grpc
from app.grpc.generated import member_pb2_grpc
from app.grpc.services import MemberService


def register_services(server: grpc.Server):
    member_pb2_grpc.add_MemberServiceServicer_to_server(MemberService(), server)

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    register_services(server)
    server.add_insecure_port("[::]:50051")
    server.start()
    server.wait_for_termination()

if __name__ == "__main__":
    serve()
