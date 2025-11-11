from __future__ import annotations

import time

from sqlalchemy.ext.asyncio import AsyncAttrs
from sqlalchemy.orm import DeclarativeBase


def millisecond_timestamp():
    return int(time.time_ns() / 1000000)


class Base(AsyncAttrs, DeclarativeBase):
    def as_dict(self):
        return {
            c.name: getattr(self, c.name)
            for c in self.__table__.columns
        }
