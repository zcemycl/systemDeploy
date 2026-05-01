from collections.abc import AsyncGenerator
from typing import Any

import strawberry
from agents._08_graphql_stream_agent import (consume_events, create_run,
                                             get_graph_definition, has_run,
                                             start_run)
from strawberry.fastapi import GraphQLRouter


@strawberry.type
class GraphNode:
    id: str
    label: str
    order: int


@strawberry.type
class GraphEdge:
    id: str
    source: str
    target: str


@strawberry.type
class GraphDefinition:
    nodes: list[GraphNode]
    edges: list[GraphEdge]


@strawberry.type
class StreamEvent:
    type: str
    run_id: str
    node_id: str | None = None
    node_label: str | None = None
    duration_ms: float | None = None
    state_json: str | None = None
    graph_json: str | None = None
    message: str | None = None


@strawberry.type
class Mutation:
    @strawberry.mutation
    async def create_run08(self) -> str:
        return create_run()

    @strawberry.mutation
    async def start_run08(self, run_id: str, prompt: str | None = None) -> bool:
        return await start_run(run_id=run_id, prompt=prompt)


@strawberry.type
class Query:
    @strawberry.field
    def graph_definition08(self) -> GraphDefinition:
        definition = get_graph_definition()
        return GraphDefinition(
            nodes=[GraphNode(**node) for node in definition["nodes"]],
            edges=[GraphEdge(**edge) for edge in definition["edges"]],
        )

    @strawberry.field
    def run_exists08(self, run_id: str) -> bool:
        return has_run(run_id)


def _to_stream_event(event: dict[str, Any]) -> StreamEvent:
    node = event.get("node") or {}
    import json

    state_json = json.dumps(event.get("state")) if "state" in event else None
    graph_json = json.dumps(event.get("graph")) if "graph" in event else None
    return StreamEvent(
        type=event.get("type", "unknown"),
        run_id=event.get("run_id", ""),
        node_id=node.get("id"),
        node_label=node.get("label"),
        duration_ms=event.get("duration_ms"),
        state_json=state_json,
        graph_json=graph_json,
        message=event.get("message"),
    )


@strawberry.type
class Subscription:
    @strawberry.subscription
    async def stream_run08(self, run_id: str) -> AsyncGenerator[StreamEvent, None]:
        async for event in consume_events(run_id):
            yield _to_stream_event(event)


schema = strawberry.Schema(query=Query, mutation=Mutation, subscription=Subscription)
graphql_08_router = GraphQLRouter(schema)
