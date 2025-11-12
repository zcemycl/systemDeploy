import strawberry
from strawberry.fastapi import GraphQLRouter

from .mutations import Mutation
from .queries import Query
from .utils.context import get_context

schema = strawberry.Schema(
    query=Query,
    mutation=Mutation,
)

graphql_app = GraphQLRouter(
    schema,
    context_getter=get_context,
)
