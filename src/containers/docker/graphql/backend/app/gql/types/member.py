import strawberry

from ..models import Member
from .message import MessageType


@strawberry.experimental.pydantic.type(model=Member, all_fields=True)
class MemberType:
    pass
