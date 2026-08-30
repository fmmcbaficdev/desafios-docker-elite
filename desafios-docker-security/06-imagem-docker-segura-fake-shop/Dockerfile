# syntax=docker/dockerfile:1.7
#
# Fake Shop — imagem endurecida
# Antes: python:3.11 (Debian full) + pip install + root + COPY . .
# Depois: python:3.11-alpine multi-stage + pip --no-cache-dir + USER 1000
# Gunicorn: modulo real e index:app (o original apontava app:app).

FROM python:3.11-alpine AS builder

# hadolint ignore=DL3018
RUN apk add --no-cache gcc musl-dev libpq-dev

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

COPY requirements.txt .
# psycopg[binary]: no Alpine o impl python nao acha libpq (ctypes/musl).
RUN python -m venv /venv \
 && /venv/bin/pip install --upgrade pip \
 && /venv/bin/pip install -r requirements.txt \
 && /venv/bin/pip install "psycopg[binary]==3.2.3"

FROM python:3.11-alpine

LABEL org.opencontainers.image.title="fake-shop" \
      org.opencontainers.image.description="Ecommerce demo — imagem endurecida"

# libpq.so (sem versao): o ctypes do psycopg no musl nao acha so o .so.5
# hadolint ignore=DL3018
RUN apk add --no-cache libpq \
 && ln -sf libpq.so.5 /usr/lib/libpq.so \
 && adduser -D -u 1000 appuser \
 && mkdir -p /tmp/metrics \
 && chown 1000:1000 /tmp/metrics

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=index.py \
    PROMETHEUS_MULTIPROC_DIR=/tmp/metrics \
    PATH="/venv/bin:$PATH"

COPY --from=builder /venv /venv
COPY --chown=1000:1000 index.py entrypoint.sh ./
COPY --chown=1000:1000 models ./models
COPY --chown=1000:1000 templates ./templates
COPY --chown=1000:1000 static ./static
COPY --chown=1000:1000 migrations ./migrations

USER 1000

EXPOSE 5000

CMD ["gunicorn", "-b", "0.0.0.0:5000", "index:app"]
