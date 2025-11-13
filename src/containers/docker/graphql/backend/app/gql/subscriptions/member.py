import json
from typing import AsyncGenerator

import redis.asyncio as redis
import strawberry
from app.core.dataclasses import member
from app.kafka import KafkaPubSub
from app.redis import CHANNEL, REDIS_URL
from loguru import logger
from sqlalchemy.sql import select

from ..types import MemberType


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
