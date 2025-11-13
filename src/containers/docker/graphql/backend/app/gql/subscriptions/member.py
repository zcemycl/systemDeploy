import json
import uuid
from typing import AsyncGenerator

import grpc
import redis.asyncio as redis
import strawberry
from app.core.dataclasses import member
from app.grpc.generated import member_pb2 as m2
from app.grpc.generated import member_pb2_grpc as m2gp
from app.kafka import KafkaPubSub
from app.redis import CHANNEL, REDIS_URL
from loguru import logger
from sqlalchemy.sql import select

from ..types import MemberType

# channel = grpc.insecure_channel("localhost:50051")
# stub = m2gp.MemberServiceStub(channel)

@strawberry.type
class MemberSubscription:
    @strawberry.subscription
    async def member_stream(self) -> AsyncGenerator[MemberType, None]:
        pubsub = KafkaPubSub(topic="members")
        try:
            async for message in pubsub.subscribe():
                yield MemberType(**message)
        finally:
            if pubsub.consumer:
                await pubsub.consumer.stop()

    @strawberry.subscription
    async def member_redis_stream(self) -> AsyncGenerator[MemberType, None]:
        r = redis.from_url(REDIS_URL, decode_responses=True)
        rpubsub = r.pubsub()
        await rpubsub.subscribe(CHANNEL)

        try:
            async for message in rpubsub.listen():
                if message["type"] == "message":
                    data = json.loads(message["data"])
                    logger.info(message)
                    yield MemberType(**data)
        except Exception as e:
            logger.info(e)
        finally:
            await rpubsub.unsubscribe(CHANNEL)
            await rpubsub.close()

    # @strawberry.subscription
    # async def member_grpc_red_stream(self) -> AsyncGenerator[MemberType, None]:
    #     async with grpc.aio.insecure_channel("localhost:50051") as channel:
    #         stub = m2gp.MemberServiceStub(channel)
    #         try:
    #             async for mem_ in stub.StreamMembers(m2.Empty()):
    #                 logger.info(mem_)
    #                 yield MemberType(name="fdsf", age=11, id=uuid.uuid4())
    #         except Exception as e:
    #             logger.info(e)
    #         finally:
    #             pass
