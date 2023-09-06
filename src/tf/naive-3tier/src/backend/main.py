from fastapi import FastAPI
import time
import asyncio

app = FastAPI()

def sync_task(task_id):
    print(f"Starting sync task {task_id}")
    time.sleep(2)
    print(f"Finished sync task {task_id}")

async def async_task(task_id):
    print(f"Starting async task {task_id}")
    await asyncio.sleep(2)
    print(f"Finished async task {task_id}")

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
    return {"result": "Async handler complete!"}
