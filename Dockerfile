FROM python:3.11-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install uv for faster, isolated installs.
RUN pip install --no-cache-dir --upgrade uv

COPY pyproject.toml README.md ./
COPY src ./src

# Install runtime dependencies into the base image.
RUN uv pip install --system .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
