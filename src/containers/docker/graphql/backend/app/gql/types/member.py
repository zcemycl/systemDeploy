import strawberry

from ..models import Member


@strawberry.experimental.pydantic.type(model=Member, all_fields=True)
class MemberType:
    pass
