from fastapi import FastAPI, UploadFile, File, Response, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import tempfile, os, trimesh

app = FastAPI(title="GLB→STL Converter")

# CORS biar gampang dipanggil dari Flutter Web juga
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], allow_methods=["*"], allow_headers=["*"],
)

@app.post("/convert")
async def convert_glb_to_stl(file: UploadFile = File(...)):
    name = (file.filename or "model.glb").lower()
    if not (name.endswith(".glb") or name.endswith(".gltf")):
        raise HTTPException(status_code=400, detail="File harus .glb / .gltf")

    # batas ukuran opsional (mis. 30 MB)
    content = await file.read()
    if len(content) > 30 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="File terlalu besar (>30MB)")

    try:
        with tempfile.NamedTemporaryFile(suffix=os.path.splitext(name)[1]) as tmp:
            tmp.write(content); tmp.flush()

            # load sebagai scene/mesh; force='mesh' akan gabung submesh jika perlu
            mesh_or_scene = trimesh.load(tmp.name, force='mesh')

            # jika scene kosong
            if mesh_or_scene is None or (hasattr(mesh_or_scene, "vertices") and len(mesh_or_scene.vertices) == 0):
                raise ValueError("Model kosong atau tidak terbaca")

            # export ke STL biner
            stl_bytes = mesh_or_scene.export(file_type="stl")
            out_name = os.path.splitext(os.path.basename(name))[0] + ".stl"

            return Response(
                content=stl_bytes,
                media_type="application/sla",  # mime STL
                headers={"Content-Disposition": f'attachment; filename="{out_name}"'}
            )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal konversi: {e}")
