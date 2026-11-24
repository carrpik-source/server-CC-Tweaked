import asyncio
import os
import websockets

CLIENTS = set()


async def handler(websocket):
    CLIENTS.add(websocket)
    try:
        async for message in websocket:
            others = CLIENTS - {websocket}
            if others:
                websockets.broadcast(others, message)
    except websockets.ConnectionClosed:
        pass
    finally:
        CLIENTS.discard(websocket)


async def main():
    port = int(os.environ.get("PORT", 8765))
    async with websockets.serve(handler, "0.0.0.0", port):
        print(f"Сервер запущен на порту {port}...")
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())
