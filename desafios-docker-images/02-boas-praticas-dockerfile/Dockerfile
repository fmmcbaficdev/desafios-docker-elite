# syntax=docker/dockerfile:1.7

# ═══════════════════════════════════════════════════════════════════════
# Rota42 - Boilerplate FastAPI - Dockerfile otimizado (multi-stage)
# ═══════════════════════════════════════════════════════════════════════
# Boas praticas aplicadas vs boilerplate original:
#   1) Tag pinada (python:3.12-slim-bookworm)   -> build reprodutivel
#   2) Base -slim                               -> ~1GB -> ~120MB
#   3) Multi-stage build                        -> runtime nao carrega toolchain
#   4) Ordem cache-friendly (deps antes de app) -> rebuild em codigo = ~1s
#   5) --mount=type=cache no pip                -> pip cache persiste entre builds
#   6) --no-cache-dir + venv isolado            -> menos lixo dentro da imagem
#   7) Non-root user (uid 1000)                 -> reduz superficie de ataque
#   8) PYTHONUNBUFFERED / PYTHONDONTWRITEBYTECODE -> logs em tempo real, sem .pyc
#   9) HEALTHCHECK                              -> orquestrador sabe quando reiniciar
# ═══════════════════════════════════════════════════════════════════════

# ─── Stage 1: builder ─────────────────────────────────────────────────
# Instala dependencias em um virtualenv isolado.
# Aqui ficaria toolchain (gcc, headers) caso alguma dep precisasse compilar.
FROM python:3.12-slim-bookworm AS builder

WORKDIR /build

# COPIA APENAS requirements.txt PRIMEIRO - se o codigo da app mudar, essa
# camada continua cacheada e o pip install nao roda de novo.
COPY requirements.txt .

# --mount=type=cache: cache do pip persiste entre builds sem ficar na imagem final.
# --no-cache-dir dentro do venv: nao guarda cache na propria imagem.
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip \
 && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# ─── Stage 2: runtime ─────────────────────────────────────────────────
# Imagem final SO tem: Python + venv com deps + codigo. Zero build tools.
FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

RUN addgroup --system --gid 1000 app \
 && adduser  --system --uid 1000 --ingroup app app

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --chown=app:app app.py .

USER app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://localhost:8000/').status==200 else 1)"

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
