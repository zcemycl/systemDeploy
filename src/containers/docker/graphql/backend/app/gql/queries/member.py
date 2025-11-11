import uuid
from typing import List

import strawberry
from app.core.dataclasses import member
from sqlalchemy.sql import select

from ..types import MemberType


@strawberry.type
class MemberQuery:
    @strawberry.field
    def member(self) -> MemberType:
        return MemberType(
            id=uuid.uuid4(),
            name="Leo Random",
            age=11,
        )

    @strawberry.field
    async def members(self, info) -> List[MemberType]:
        session = info.context["session"]
        result = (await session.execute(select(member)))
        members = result.scalars().all()
        return [
            MemberType(
                id=m.id,
                name=m.name,
                age=m.age,
            )
            for m in members
        ]
