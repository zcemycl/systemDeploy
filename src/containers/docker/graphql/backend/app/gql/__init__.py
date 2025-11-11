import strawberry
from strawberry.fastapi import GraphQLRouter

from .mutations import Mutation
from .queries import Query

schema = strawberry.Schema(
    query=Query,
    # mutation=Mutation,
)

graphql_app = GraphQLRouter(
    schema,
)
