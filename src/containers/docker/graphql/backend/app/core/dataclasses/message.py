from __future__ import annotations

import uuid
from typing import TYPE_CHECKING

from sqlalchemy import (BigInteger, Column, DateTime, ForeignKey, Integer,
                        String)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..database import Base, millisecond_timestamp

if TYPE_CHECKING:
    from .member import member

class message(Base):
    __tablename__ = "message"

    id = Column(
        "id", UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    content = Column("content", String, nullable=False)
    created_at: Mapped[DateTime] = mapped_column(
        "created_at",
        BigInteger,
        nullable=False,
        default=millisecond_timestamp,
    )
    member_id: Mapped[UUID] = mapped_column(
        ForeignKey("member.id", ondelete="CASCADE"), nullable=True
    )
    member: Mapped["member"] = relationship(
        back_populates="message",
    )
