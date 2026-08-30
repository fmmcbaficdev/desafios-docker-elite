# syntax=docker/dockerfile:1.7
#
# Fake Shop — Distroless Chainguard
# Builder (-dev): pip + shell. Runtime (latest): Distroless, UID 65532.
# Catalogo publico Chainguard: so latest (hoje Python 3.14).
# greenlet==3.1.1 do enunciado nao compilava em 3.14 → instala greenlet>=3.2.

FROM cgr.dev/chainguard/python:latest-dev AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PATH="/app/venv/bin:$PATH"

COPY requirements.txt .
RUN python -m venv /app/venv \
 && pip install --upgrade pip \
 && grep -v '^greenlet==' requirements.txt > /tmp/req.txt \
 && pip install -r /tmp/req.txt \
 && pip install "greenlet>=3.2" "psycopg[binary]>=3.2.10" "SQLAlchemy>=2.0.40" \
 && mkdir -p /app/metrics

FROM cgr.dev/chainguard/python:latest

LABEL org.opencontainers.image.title="fake-shop-distroless" \
      org.opencontainers.image.description="Fake Shop em imagem Distroless Chainguard"

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=index.py \
    PROMETHEUS_MULTIPROC_DIR=/tmp/metrics \
    PATH="/app/venv/bin:$PATH"

COPY --from=builder --chown=65532:65532 /app/venv /app/venv
COPY --from=builder --chown=65532:65532 /app/metrics /tmp/metrics
COPY --chown=65532:65532 index.py ./
COPY --chown=65532:65532 models ./models
COPY --chown=65532:65532 templates ./templates
COPY --chown=65532:65532 static ./static
COPY --chown=65532:65532 migrations ./migrations

USER 65532

EXPOSE 5000

# Sobrescreve o ENTRYPOINT da base (/usr/bin/python) — gunicorn vive no venv.
ENTRYPOINT ["/app/venv/bin/python"]
CMD ["-m", "gunicorn", "-b", "0.0.0.0:5000", "index:app"]
