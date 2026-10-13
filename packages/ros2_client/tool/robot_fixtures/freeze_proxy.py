"""A TCP proxy that can go silent without closing, like a Wi-Fi dropout.

    python3 freeze_proxy.py LISTEN_PORT BRIDGE_PORT
    kill -USR1 <pid>      # from now on, forward nothing and close nothing

Neither side sees an error or a close; bytes simply stop arriving. That is
what a robot losing power or a laptop leaving Wi-Fi range looks like to a
WebSocket, and the only defence is noticing the silence.
"""
import signal
import socket
import sys
import threading
import time

frozen = False


def freeze(*_):
    global frozen
    frozen = True
    print('frozen', flush=True)


def pump(src, dst):
    try:
        while True:
            data = src.recv(65536)
            if not data:
                break
            while frozen:
                time.sleep(1)
            dst.sendall(data)
    except OSError:
        pass
    while frozen:
        time.sleep(1)


def main():
    listen_port, bridge_port = int(sys.argv[1]), int(sys.argv[2])
    signal.signal(signal.SIGUSR1, freeze)
    server = socket.socket()
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('127.0.0.1', listen_port))
    server.listen(5)
    while True:
        client, _ = server.accept()
        upstream = socket.create_connection(('127.0.0.1', bridge_port))
        for a, b in ((client, upstream), (upstream, client)):
            threading.Thread(target=pump, args=(a, b), daemon=True).start()


if __name__ == '__main__':
    main()
