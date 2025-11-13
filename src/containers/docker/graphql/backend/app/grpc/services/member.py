import app.grpc.generated.member_pb2 as mpb2
import app.grpc.generated.member_pb2_grpc as mpb2g
import grpc
from app.core.database import async_session


class MemberService(mpb2g.MemberServiceServicer):
    def __init__(self):
        self.async_session = async_session
