# ---- build stage ----
FROM python:3.12-slim AS builder

ENV PIP_NO_CACHE_DIR=1 PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

# non-root user early
RUN useradd -u 10001 -m appuser
WORKDIR /app

# build tools then remove apt cache
RUN apt-get update && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=appuser:appuser requirements.txt .
RUN pip wheel --wheel-dir /wheels -r requirements.txt

# ---- runtime stage ----
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

RUN useradd -u 10001 -m appuser
WORKDIR /app

COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir --no-index --find-links=/wheels /wheels/* && rm -rf /wheels

COPY --chown=appuser:appuser app.py .
COPY --chown=appuser:appuser requirements.txt .

USER 10001
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/').read()"
CMD ["python", "app.py"]
