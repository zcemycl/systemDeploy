import os
from typing import Iterator

from loguru import logger
from sqlalchemy.ext.asyncio import (AsyncSession, async_sessionmaker,
                                    create_async_engine)

db_async_url = f"postgresql+asyncpg://{os.environ['PGUSER']}:{os.environ['PGPASSWORD']}@{os.environ['PGHOST']}/{os.environ['PGDATABASE']}"
logger.info(f"new: {db_async_url}")

async_engine = create_async_engine(db_async_url)


async def get_async_session() -> Iterator[AsyncSession]:
    session = async_sessionmaker(
        async_engine,
        autocommit=False,
        autoflush=False,
        # bind=create_async_engine(db_async_url),
        class_=AsyncSession,
        expire_on_commit=False,
    )
    async with session() as sess:
        yield sess
