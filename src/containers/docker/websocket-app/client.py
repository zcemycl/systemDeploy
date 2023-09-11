import socketio
import asyncio

loop = asyncio.get_event_loop()
sio_client = socketio.AsyncClient()

async def send_ping():
    await sio_client.emit('ping_from_client')

@sio_client.event
async def connect():
    print("I am connected.")
    await send_ping()

@sio_client.event
async def disconnect():
    print("I am disconnected.")

@sio_client.event
async def pong_from_server():
    print("trigger pong")
    await sio_client.sleep(1)
    if sio_client.connected:
        await send_ping()

async def main():
    await sio_client.connect(url="http://localhost:8000", socketio_path="sockets")
    # await sio_client.disconnect()
    await sio_client.wait()

loop.run_until_complete(main())
