import uuid

import strawberry

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
