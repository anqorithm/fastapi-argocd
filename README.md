# fastapi-argocd

Minimal FastAPI service with one endpoint, packaged for local development and deployment to MicroK8s via a local registry. All instructions are in English and use `uv` for dependency management. Source lives in `src/app`.

## App
- Endpoint: `GET /health` → `{"status": "ok"}`
- Run locally with auto-reload:
  ```bash
  pip install uv  # if you don't have it yet
  uv venv
  source .venv/bin/activate
  uv sync
  uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
  ```
- Quick test: `curl http://127.0.0.1:8000/health`

## Docker (local build, local registry)
```bash
docker build -t localhost:32000/fastapi-argocd:latest .
docker push localhost:32000/fastapi-argocd:latest
```

## 🟩 1. Install MicroK8s
```bash
sudo snap install microk8s --classic
sudo usermod -aG microk8s $USER
newgrp microk8s
microk8s status --wait-ready
microk8s enable dns storage ingress
```

## 🟩 2. Enable the Local Registry
```bash
microk8s enable registry
# registry address: localhost:32000
```

## 🟩 3. Allow Docker to Push to the Local Registry
Edit `/etc/docker/daemon.json`:
```json
{
  "insecure-registries": ["localhost:32000"]
}
```
Then restart Docker:
```bash
sudo systemctl restart docker
```

## 🟩 4. Build & Push the Image Locally
```bash
docker build -t localhost:32000/fastapi-argocd:latest .
docker push localhost:32000/fastapi-argocd:latest
```

## 🟩 5. Deploy to MicroK8s
```bash
microk8s kubectl apply -f k8s/
```
Kubernetes manifests live in `k8s/`:
- `deployment.yaml` (image: `localhost:32000/fastapi-argocd:latest`)
- `service.yaml` (ClusterIP on port 80 → container port 8000)
- `ingress.yaml` (optional; host `fastapi.local`)

## 🟩 6. (Optional) Local CI/CD with `act`
Install `act`:
```bash
sudo snap install act   # Ubuntu
# or: brew install act  # macOS
```
Workflow: `.github/workflows/local.yml`
Run locally:
```bash
act push
```
This will build the Docker image, push to `localhost:32000`, and apply the manifests via `microk8s kubectl`.

## Notes
- Uses `uv` for Python dependency management and `uvicorn` as the ASGI server.
- The image is set to `imagePullPolicy: Always` so new pushes to the local registry are picked up immediately.
- If you use the ingress, add a hosts entry such as `127.0.0.1 fastapi.local`.
