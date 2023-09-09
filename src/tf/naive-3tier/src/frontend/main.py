import os
from flask import Flask
import asyncio
import requests
import aiohttp
from loguru import logger

BACKEND_HOST = os.environ["BACKEND_HOST"]
logger.info(f"Backend Host: {BACKEND_HOST}")
app = Flask(__name__)

async def fetch_url(session, url):
    """Fetch the specified URL using the aiohttp session specified."""
    response = await session.get(url)
    return {'url': response.url,
        'status': response.status,
        "json": await response.json()}

@app.route("/")
def hello_world():
    return "<h4>Hello World!</h4>"

@app.route("/async")
async def async_page():
    async with aiohttp.ClientSession() as session:
        tasks = []
        task = asyncio.create_task(fetch_url(session, f"{BACKEND_HOST}/async"))
        tasks.append(task)
        results = await asyncio.gather(*tasks)

    res = ""
    for result in results:
        logger.info(result)
        res = result['json']['result']
    return f"<h4>{res}!</h4>"
