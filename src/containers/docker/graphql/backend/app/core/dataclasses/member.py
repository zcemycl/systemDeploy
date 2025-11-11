from __future__ import annotations

import uuid
from typing import TYPE_CHECKING, List

from sqlalchemy import BigInteger, Column, DateTime, Integer, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..database import Base

if TYPE_CHECKING:
    from .message import message

class member(Base):
    __tablename__ = "member"

    id = Column(
        "id", UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    name = Column("name", String, nullable=False)
    age = Column("age", Integer, nullable=False)
    messages: Mapped[List["message"]] = relationship(
        back_populates="member"
    )
