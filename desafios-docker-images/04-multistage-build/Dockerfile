# syntax=docker/dockerfile:1.7

# ═══════════════════════════════════════════════════════════════════════
# Rota42 - Video Converter (Go + FFmpeg) - Multistage Build
# ═══════════════════════════════════════════════════════════════════════
# Stage builder:  toolchain Go (centenas de MB) - DESCARTADO no final
# Stage runtime:  Alpine + ffmpeg + binario estatico (~poucos MB)
#
# Resultado: mesma funcionalidade do Dockerfile naive, sem o SDK.
# ═══════════════════════════════════════════════════════════════════════

# ── Stage 1: builder ──────────────────────────────────────────────────
FROM golang:1.23-alpine AS builder

WORKDIR /src

# go.mod primeiro - cacheia o download de deps se o codigo mudar.
COPY go.mod ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY converter.go ./

# -s -w remove tabela de simbolos e DWARF -> binario menor.
# CGO_ENABLED=0: binario 100% estatico, nao depende de libc do builder.
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/converter .

# ── Stage 2: runtime ──────────────────────────────────────────────────
# ffmpeg precisa ficar no runtime (o conversor chama o binario).
# Alpine e a menor distro oficial que empacota ffmpeg + libx264/aac.
FROM alpine:3.20

LABEL org.opencontainers.image.title="rota42-video-converter-go" \
      org.opencontainers.image.description="Conversor de videos em Go, imagem multi-stage" \
      org.opencontainers.image.source="https://github.com/fmmcbaficdev/desafios-docker-elite"

RUN apk add --no-cache ffmpeg \
 && addgroup -S -g 1000 converter \
 && adduser  -S -u 1000 -G converter converter

COPY --from=builder --chmod=755 --chown=converter:converter /out/converter /usr/local/bin/converter

WORKDIR /work
USER converter

# ENTRYPOINT fixo + CMD default (mesmo contrato do desafio 03).
ENTRYPOINT ["/usr/local/bin/converter"]
CMD ["--help"]
