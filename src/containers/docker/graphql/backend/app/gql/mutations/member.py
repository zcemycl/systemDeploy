import strawberry
from app.core.dataclasses import member
from app.kafka import KafkaPubSub

from ..types import MemberType

pubsub = KafkaPubSub(topic="members")

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
        await pubsub.publish({
            **new_member_type.__dict__,
            "id": str(new_member_type.id),
        })
        return new_member_type
