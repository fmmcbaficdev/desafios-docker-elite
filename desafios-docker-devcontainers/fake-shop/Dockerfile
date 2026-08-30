# syntax=docker/dockerfile:1.7
# Produção: Alpine multi-stage, venv, non-root, gunicorn.

FROM python:3.11-alpine AS builder

# hadolint ignore=DL3018
RUN apk add --no-cache gcc musl-dev libpq-dev

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

COPY src/requirements.txt .
RUN python -m venv /venv \
 && /venv/bin/pip install --upgrade pip \
 && /venv/bin/pip install -r requirements.txt \
 && /venv/bin/pip install "psycopg[binary]==3.2.3"

FROM python:3.11-alpine

LABEL org.opencontainers.image.title="fake-shop" \
      org.opencontainers.image.description="Fake Shop — imagem de produção"

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
    FLASK_ENV=production \
    APP_ENV=production \
    FLASK_DEBUG=0 \
    PROMETHEUS_MULTIPROC_DIR=/tmp/metrics \
    PATH="/venv/bin:$PATH"

COPY --from=builder /venv /venv
COPY --chown=1000:1000 src/index.py ./
COPY --chown=1000:1000 src/models ./models
COPY --chown=1000:1000 src/templates ./templates
COPY --chown=1000:1000 src/static ./static
COPY --chown=1000:1000 src/migrations ./migrations

USER 1000

EXPOSE 5000

# sh (não o entrypoint.sh do Windows, que vem com CRLF).
CMD ["sh", "-c", "python -m flask db upgrade && python -m gunicorn --bind 0.0.0.0:5000 index:app"]
