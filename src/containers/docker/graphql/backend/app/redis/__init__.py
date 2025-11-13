import json
from typing import AsyncGenerator

import redis.asyncio as redis
from app.gql.types import MessageType

REDIS_URL = "redis://localhost:6379"
CHANNEL = "chatroom"


async def redis_publisher(message: dict):
    r = redis.from_url(REDIS_URL, decode_responses=True)
    await r.publish(CHANNEL, json.dumps(message))
    await r.close()


async def redis_subscriber() -> AsyncGenerator[MessageType, None]:
    r = redis.from_url(REDIS_URL, decode_responses=True)
    pubsub = r.pubsub()
    await pubsub.subscribe(CHANNEL)

    try:
        async for msg in pubsub.listen():
            if msg["type"] == "message":
                data = json.loads(msg["data"])
                yield MessageType(**data)
    finally:
        await pubsub.unsubscribe(CHANNEL)
        await pubsub.close()
