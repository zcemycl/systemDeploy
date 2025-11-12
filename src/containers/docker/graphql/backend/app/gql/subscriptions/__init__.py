import strawberry

from .member import MemberSubscription


@strawberry.type
class Subscription(MemberSubscription):
    pass
