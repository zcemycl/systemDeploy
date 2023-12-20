import socketio
import uvicorn
from fastapi import FastAPI
from loguru import logger

app = FastAPI()
sio = socketio.AsyncServer(async_mode="asgi", cors_allowed_origins=["*"])
sio_app = socketio.ASGIApp(socketio_server=sio, socketio_path="sockets")
app.mount("/", app=sio_app)

@app.get("/")
async def home():
    return {"message": "Hello World!"}

@sio.event
async def connect(sid, environ, auth):
    logger.info(f"{sid}: connected")
    await sio.emit('join', {'sid': sid})

@sio.on("ping_from_client")
async def ping_from_client_func(sid):
    logger.info(f"{sid}: trigger ping")
    await sio.emit('pong_from_server', room=sid)

@sio.on("*")
async def catch_all(event, data):
    logger.info(f"{event}")
    logger.info(f"{data}")

@sio.event
async def disconnect(sid):
    logger.info(f"{sid}: disconnected")

if __name__ == "__main__":
    uvicorn.run("main:app", reload=True)
