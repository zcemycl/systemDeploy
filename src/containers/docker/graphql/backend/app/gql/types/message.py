import strawberry

from ..models import Message


@strawberry.experimental.pydantic.type(model=Message, all_fields=True)
class MessageType:
    pass
