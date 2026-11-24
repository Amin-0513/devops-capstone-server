import os
import json
import socket
import random
import string
import hashlib

HOST = "0.0.0.0"
PORT = int(os.environ.get("PORT", 5000))
DATA_DIR = "/serverdata"
FILE_NAME = "random_file.txt"
FILE_SIZE = 1024  # 1 KB


def create_random_file():
    """Create a 1 KB file of random text in /serverdata."""
    os.makedirs(DATA_DIR, exist_ok=True)
    path = os.path.join(DATA_DIR, FILE_NAME)
    text = "".join(random.choices(string.ascii_letters + string.digits, k=FILE_SIZE))
    with open(path, "w") as f:
        f.write(text)
    print(f"[server] Created {path} ({os.path.getsize(path)} bytes)")
    return path


def sha256_of(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        h.update(f.read())
    return h.hexdigest()


def main():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind((HOST, PORT))
        s.listen(5)
        print(f"[server] Listening on {HOST}:{PORT}")

        while True:
            conn, addr = s.accept()
            with conn:
                print(f"[server] Client connected from {addr}")
                path = create_random_file()
                checksum = sha256_of(path)
                with open(path, "rb") as f:
                    data = f.read()

                # Protocol: one JSON header line, then the raw file bytes
                header = json.dumps({
                    "filename": FILE_NAME,
                    "size": len(data),
                    "checksum": checksum,
                }) + "\n"
                conn.sendall(header.encode() + data)
                print(f"[server] Sent {FILE_NAME} with SHA-256 {checksum}")


if __name__ == "__main__":
    main()