import strawberry

from .member import MemberQuery


@strawberry.type
class Query(MemberQuery):
    pass
