from app.core.database.session import async_session


async def get_context():
    async with async_session() as session:
        return {"session": session}
