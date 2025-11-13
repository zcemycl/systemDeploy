import strawberry
from app.core.dataclasses import member
from app.kafka import pubsub
from app.redis import redis_publisher

from ..types import MemberType


@strawberry.type
class MemberMutation:
    @strawberry.mutation
    async def create_member(
        self,
        info: strawberry.Info,
        name: str,
        age: int,
    ) -> MemberType:
        session = info.context["session"]
        new_member = member(
            name=name,
            age=age,
        )
        session.add(new_member)
        await session.commit()
        await session.refresh(new_member)
        new_member_type = MemberType(
            id=new_member.id,
            name=new_member.name,
            age=new_member.age
        )
        payload = {
            **new_member_type.__dict__,
            "id": str(new_member_type.id),
        }
        await pubsub.publish(payload)
        await redis_publisher(payload)
        return new_member_type
