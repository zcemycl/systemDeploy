import uvicorn
from fastapi import FastAPI
import socketio


app = FastAPI()
sio = socketio.AsyncServer(async_mode="asgi", cors_allowed_origins=["*"])
sio_app = socketio.ASGIApp(socketio_server=sio, socketio_path="sockets")
app.mount("/", app=sio_app)

@app.get("/")
async def home():
    return {"message": "Hello World!"}

@sio.event
async def connect(sid, environ, auth):
    print(f"{sid}: connected")
    await sio.emit('join', {'sid': sid})

@sio.event
async def ping_from_client(sid):
    print("trigger ping")
    await sio.emit('pong_from_server', room=sid)

@sio.event
async def disconnect(sid):
    print(f"{sid}: disconnected")

if __name__ == "__main__":
    uvicorn.run("main:app", reload=True)
