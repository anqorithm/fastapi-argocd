from fastapi import FastAPI

app = FastAPI(title="fastapi-argocd", version="0.1.0")


@app.get("/health", tags=["health"])
def health():
    """Simple health endpoint for uptime checks."""
    return {"status": "ok"}
