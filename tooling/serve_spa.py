from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import os

ROOT = Path(__file__).resolve().parents[1] / "build" / "web"
HOST = "127.0.0.1"
PORT = 5317


class SpaHandler(SimpleHTTPRequestHandler):
    def send_head(self):
        requested = Path(self.translate_path(self.path))
        if not requested.exists() and not self.path.startswith(("/assets/", "/canvaskit/")):
            self.path = "/index.html"
        return super().send_head()


if __name__ == "__main__":
    os.chdir(ROOT)
    print(f"Serving GiftPath at http://{HOST}:{PORT}")
    ThreadingHTTPServer((HOST, PORT), SpaHandler).serve_forever()
