import os, io, json
from http.server import BaseHTTPRequestHandler, HTTPServer
from supabase import create_client
import trimesh

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")  # perlu write ke Storage
INPUT_BUCKET = os.environ.get("INPUT_BUCKET", "models-glb")
OUTPUT_BUCKET = os.environ.get("OUTPUT_BUCKET", "models-stl")

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def convert_glb_to_stl_bytes(glb_bytes: bytes) -> bytes:
    mesh = trimesh.load(io.BytesIO(glb_bytes), file_type='glb')
    if isinstance(mesh, trimesh.Scene):
        mesh = trimesh.util.concatenate(mesh.dump())  # flatten scene
    stl = mesh.export(file_type='stl')
    return stl if isinstance(stl, (bytes, bytearray)) else stl.encode()

class Handler(BaseHTTPRequestHandler):
    def _send(self, code, payload, content_type="application/json"):
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        # CORS (opsional)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.end_headers()
        self.wfile.write(payload if isinstance(payload, (bytes, bytearray)) else payload.encode())

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.end_headers()

    def do_POST(self):
        try:
            length = int(self.headers.get('content-length', 0))
            body = json.loads(self.rfile.read(length) or "{}")
            path = body.get("path")
            if not path:
                return self._send(400, json.dumps({"error":"Missing 'path'"}))

            # Download GLB dari Storage
            glb_bytes = supabase.storage.from_(INPUT_BUCKET).download(path)

            # Convert
            stl_bytes = convert_glb_to_stl_bytes(glb_bytes)
            stl_path = path.rsplit(".", 1)[0] + ".stl"

            # Upload STL ke Storage (upsert)
            supabase.storage.from_(OUTPUT_BUCKET).upload(
                path=stl_path,
                file=io.BytesIO(stl_bytes),
                file_options={"contentType":"model/stl", "upsert": True}
            )

            # Signed URL 1 jam
            signed = supabase.storage.from_(OUTPUT_BUCKET).create_signed_url(stl_path, 60*60)
            return self._send(200, json.dumps({
                "ok": True,
                "stl_path": stl_path,
                "stl_url": signed.get("signedURL")
            }))
        except Exception as e:
            return self._send(500, json.dumps({"error": str(e)}))

def run():
    port = int(os.environ.get("PORT", "8080"))
    HTTPServer(("", port), Handler).serve_forever()

if __name__ == "__main__":
    run()
