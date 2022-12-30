from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
from asyncio import sleep

BUFFER_SIZE = 65536
SLEEP_DURATION = 1e-3

app = FastAPI()

async def random_data(size: int):
    bytes_sent = 0
    while bytes_sent < size:
        if bytes_sent + BUFFER_SIZE >= size:
            bytes_to_send = size - bytes_sent
        else:
            bytes_to_send = BUFFER_SIZE

        yield b"q" * bytes_to_send
        bytes_sent += bytes_to_send
        # await sleep(SLEEP_DURATION)

@app.get("/{size}")
async def main(request: Request, size: int):
    range_header = request.headers.get("Range")

    if range_header is not None:
        tokens = range_header.split("=")[1].split("-")
        size = min(size, int(tokens[1]) - int(tokens[0]) + 1)

    return StreamingResponse(
        random_data(size), 
        media_type = "application/octet-stream", 
        headers = {
            "Accept-Ranges": "bytes",
            "Content-Length": str(size)
        }
    )
