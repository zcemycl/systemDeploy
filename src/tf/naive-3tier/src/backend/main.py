import asyncio
import os
import time

from fastapi import FastAPI
from loguru import logger
from sqlalchemy import create_engine, text

RDS_HOST = os.environ["RDS_HOST"]
RDS_PWD = os.environ["RDS_PWD"]
logger.info(f"Rds Host: {RDS_HOST}")
app = FastAPI()

engine = create_engine(f"postgresql://postgres:{RDS_PWD}@{RDS_HOST}:5432/postgres")

def sync_task(task_id):
    print(f"Starting sync task {task_id}")
    time.sleep(2)
    print(f"Finished sync task {task_id}")

async def async_task(task_id):
    print(f"Starting async task {task_id}")
    await asyncio.sleep(2)
    print(f"Finished async task {task_id}")

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/test_rds_connect")
def test_rds_connect():
    try:
        with engine.connect() as connection:
            result = connection.execute(text("select * from persons"))
            for row in result:
                print(row)
    except Exception as e:
        logger.info(str(e))
        return {"message": "error"}
    return {"message": "success"}

@app.get("/sync")
def sync_handler():
    sync_task(1)
    sync_task(2)
    sync_task(3)
    return {"result": "Sync handler complete!"}

@app.get("/async")
async def async_handler():
    tasks = [async_task(1), async_task(2), async_task(3)]
    await asyncio.gather(*tasks)
    return {"result": "Async handler complete!!"}
