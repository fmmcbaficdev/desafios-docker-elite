# syntax=docker/dockerfile:1.7
#
# Kube News — Distroless Chainguard
# Builder (-dev): npm + shell. Runtime (latest): sem shell, sem gerenciador de pacotes, UID 65532.
# ENTRYPOINT da base: /usr/bin/node. CMD so o script.

FROM cgr.dev/chainguard/node:latest-dev AS builder

WORKDIR /app
ENV NODE_ENV=production

COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts

COPY server.js middleware.js system-life.js ./
COPY models ./models
COPY views ./views
COPY static ./static

FROM cgr.dev/chainguard/node:latest

LABEL org.opencontainers.image.title="kube-news-distroless" \
      org.opencontainers.image.description="Kube News em imagem Distroless Chainguard"

WORKDIR /app
ENV NODE_ENV=production \
    PORT=8080

COPY --from=builder --chown=65532:65532 /app /app

USER 65532

EXPOSE 8080

CMD ["server.js"]
