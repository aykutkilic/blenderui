"""Loopback WebSocket to stdio Language Server Protocol bridge.

CodeForge can speak LSP over WebSocket from sandboxed desktop applications,
while Python language servers normally expose Content-Length framed stdio.
This companion keeps process execution outside the app sandbox and starts one
isolated language-server process per WebSocket client.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import sys
from asyncio.subprocess import PIPE, Process
from collections.abc import Sequence

from websockets.asyncio.server import ServerConnection, serve
from websockets.exceptions import ConnectionClosed


async def _read_message(process: Process) -> str | None:
    assert process.stdout is not None
    content_length: int | None = None
    while True:
        line = await process.stdout.readline()
        if not line:
            return None
        if line in (b"\r\n", b"\n"):
            break
        name, _, value = line.decode("ascii").partition(":")
        if name.lower() == "content-length":
            content_length = int(value.strip())
    if content_length is None:
        raise RuntimeError("LSP message has no Content-Length header")
    payload = await process.stdout.readexactly(content_length)
    return payload.decode("utf-8")


async def _write_message(process: Process, message: str) -> None:
    assert process.stdin is not None
    # Validate before forwarding so malformed WebSocket input cannot corrupt
    # the framed language-server stream.
    parsed = json.loads(message)
    print(
        f"client -> LSP {parsed.get('method', 'response')} "
        f"id={parsed.get('id', '-')}",
        flush=True,
    )
    payload = message.encode("utf-8")
    process.stdin.write(f"Content-Length: {len(payload)}\r\n\r\n".encode("ascii"))
    process.stdin.write(payload)
    await process.stdin.drain()


async def _relay_stderr(process: Process) -> None:
    assert process.stderr is not None
    while line := await process.stderr.readline():
        sys.stderr.buffer.write(line)
        sys.stderr.buffer.flush()


async def _handle_client(
    socket: ServerConnection,
    server_command: Sequence[str],
) -> None:
    process = await asyncio.create_subprocess_exec(
        *server_command,
        stdin=PIPE,
        stdout=PIPE,
        stderr=PIPE,
    )

    async def server_to_socket() -> None:
        while (message := await _read_message(process)) is not None:
            parsed = json.loads(message)
            print(
                f"LSP -> client {parsed.get('method', 'response')} "
                f"id={parsed.get('id', '-')}",
                flush=True,
            )
            await socket.send(message)

    async def socket_to_server() -> None:
        async for message in socket:
            if not isinstance(message, str):
                raise TypeError("LSP bridge accepts text WebSocket frames only")
            await _write_message(process, message)

    tasks = {
        asyncio.create_task(server_to_socket()),
        asyncio.create_task(socket_to_server()),
        asyncio.create_task(_relay_stderr(process)),
    }
    try:
        done, _ = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
        for task in done:
            try:
                task.result()
            except ConnectionClosed:
                pass
    finally:
        for task in tasks:
            task.cancel()
        await asyncio.gather(*tasks, return_exceptions=True)
        if process.stdin is not None:
            process.stdin.close()
        try:
            await asyncio.wait_for(process.wait(), timeout=2)
        except TimeoutError:
            process.terminate()
            await process.wait()


async def _main(arguments: argparse.Namespace) -> None:
    command = [arguments.server, *arguments.server_args]
    async with serve(
        lambda socket: _handle_client(socket, command),
        arguments.host,
        arguments.port,
        max_size=16 * 1024 * 1024,
    ):
        print(
            f"LSP WebSocket bridge listening on ws://{arguments.host}:{arguments.port}",
            flush=True,
        )
        await asyncio.Future()


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=5656)
    parser.add_argument("--server", required=True)
    parser.add_argument("server_args", nargs=argparse.REMAINDER)
    parsed = parser.parse_args()
    if parsed.server_args[:1] == ["--"]:
        parsed.server_args = parsed.server_args[1:]
    return parsed


if __name__ == "__main__":
    try:
        asyncio.run(_main(_parse_args()))
    except KeyboardInterrupt:
        pass
