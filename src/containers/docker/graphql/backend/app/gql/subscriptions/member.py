import uuid
from typing import AsyncGenerator

import strawberry
from app.core.dataclasses import member
from app.kafka import KafkaPubSub
from sqlalchemy.sql import select

from ..types import MemberType

pubsub = KafkaPubSub(topic="members")

@strawberry.type
class MemberSubscription:
    @strawberry.subscription
    async def member_stream(self) -> AsyncGenerator[MemberType, None]:
        async for message in pubsub.subscribe():
            yield MemberType(**message)
