import uuid
from typing import List

import strawberry
from app.core.dataclasses import member
from sqlalchemy.sql import select

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
        return MemberType(
            id=new_member.id,
            name=new_member.name,
            age=new_member.age
        )
