import strawberry

from .member import MemberMutation


@strawberry.type
class Mutation(MemberMutation):
    pass
