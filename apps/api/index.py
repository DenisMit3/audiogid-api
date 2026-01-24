from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"status": "WORKING!", "message": "Minimal FastAPI test on Vercel"}

@app.get("/v1/ops/health")
def health():
    return {"status": "ok", "test": True}
