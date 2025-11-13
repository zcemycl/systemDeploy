
import json

import redis.asyncio as redis
from app.core.database.session import async_session
from loguru import logger

from ..generated import member_pb2 as mpb2
from ..generated import member_pb2_grpc as mpb2g

REDIS_URL = "redis://localhost:6379"
CHANNEL = "chatroom"



class MemberService(mpb2g.MemberServiceServicer):
    def __init__(self):
        self.async_session = async_session

    async def StreamMembers(self, request, context):
        r = redis.from_url(REDIS_URL, decode_responses=True)
        rpubsub = r.pubsub()
        await rpubsub.subscribe(CHANNEL)

        try:
            async for message in rpubsub.listen():
                if message["type"] == "message":
                    data = json.loads(message["data"])
                    logger.info(message)
                    yield mpb2.MemberReply(
                        id=data["id"],
                        name=data["name"],
                        age=data["age"],
                    )
        except Exception as e:
            logger.info(e)
        finally:
            await rpubsub.unsubscribe(CHANNEL)
            await rpubsub.close()
