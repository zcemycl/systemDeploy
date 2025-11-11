from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING, List
from uuid import UUID

from pydantic import BaseModel


class Message(BaseModel):
    id: UUID
    content: str
    created_at: datetime
