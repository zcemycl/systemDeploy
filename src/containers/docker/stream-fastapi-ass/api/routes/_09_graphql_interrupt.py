import json
from collections.abc import AsyncGenerator
from typing import Any

import strawberry
from agents._09_graphql_interrupt_agent import (create_run,
                                                get_graph_definition, has_run,
                                                stream_run_events,
                                                submit_review_decision)
from strawberry.fastapi import GraphQLRouter


@strawberry.type
class GraphNode:
    id: str
    label: str
    order: int
    is_review: bool


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
    is_review: bool | None = None
    duration_ms: float | None = None
    state_json: str | None = None
    graph_json: str | None = None
    payload_json: str | None = None
    decision_json: str | None = None
    allowed_actions: list[str] | None = None
    stopped_reason: str | None = None
    message: str | None = None


@strawberry.input
class ReviewDecisionInput:
    node_id: str
    action: str
    edited_text: str | None = None
    comment: str | None = None


@strawberry.type
class Query:
    @strawberry.field
    def graph_definition09(self) -> GraphDefinition:
        definition = get_graph_definition()
        return GraphDefinition(
            nodes=[GraphNode(**node) for node in definition["nodes"]],
            edges=[GraphEdge(**edge) for edge in definition["edges"]],
        )

    @strawberry.field
    def run_exists09(self, run_id: str) -> bool:
        return has_run(run_id)


@strawberry.type
class Mutation:
    @strawberry.mutation
    def create_run09(self) -> str:
        return create_run()

    @strawberry.mutation
    async def submit_review_decision09(
        self, run_id: str, decision: ReviewDecisionInput
    ) -> bool:
        if decision.action not in {"approve", "reject", "edit"}:
            return False
        if decision.node_id not in {"b_review", "c_review", "d_review"}:
            return False
        return await submit_review_decision(
            run_id=run_id,
            decision={
                "node_id": decision.node_id,
                "action": decision.action,
                "edited_text": decision.edited_text,
                "comment": decision.comment,
            },
        )


def _to_stream_event(event: dict[str, Any]) -> StreamEvent:
    node = event.get("node") or {}
    state_json = json.dumps(event.get("state")) if "state" in event else None
    graph_json = json.dumps(event.get("graph")) if "graph" in event else None
    payload_json = json.dumps(event.get("payload")) if "payload" in event else None
    decision_json = json.dumps(event.get("decision")) if "decision" in event else None
    return StreamEvent(
        type=event.get("type", "unknown"),
        run_id=event.get("run_id", ""),
        node_id=node.get("id"),
        node_label=node.get("label"),
        is_review=node.get("is_review"),
        duration_ms=event.get("duration_ms"),
        state_json=state_json,
        graph_json=graph_json,
        payload_json=payload_json,
        decision_json=decision_json,
        allowed_actions=event.get("allowed_actions"),
        stopped_reason=event.get("stopped_reason"),
        message=event.get("message"),
    )


@strawberry.type
class Subscription:
    @strawberry.subscription
    async def stream_run09(self, run_id: str) -> AsyncGenerator[StreamEvent, None]:
        async for event in stream_run_events(run_id=run_id):
            yield _to_stream_event(event)


schema = strawberry.Schema(query=Query, mutation=Mutation, subscription=Subscription)
graphql_09_router = GraphQLRouter(schema)
