from __future__ import annotations

from typing import TYPE_CHECKING, List
from uuid import UUID

from pydantic import BaseModel

from .message import Message


class Member(BaseModel):
    id: UUID
    name: str
    age: int
    messages: List["Message"]
