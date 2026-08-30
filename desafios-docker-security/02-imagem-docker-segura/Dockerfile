# syntax=docker/dockerfile:1.7

# Kube News — imagem endurecida
# Antes: node:23.9.0 (Debian full) + npm install + root  → ~1.7 GB
# Depois: node:23.9.0-alpine + npm ci --omit=dev + USER node

FROM node:23.9.0-alpine

LABEL org.opencontainers.image.title="kube-news" \
      org.opencontainers.image.description="Portal de noticias — imagem endurecida"

WORKDIR /app

# Deps primeiro (cache). npm ci e reproduzivel e nao instala devDependencies.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts \
 && npm cache clean --force

# So o codigo da aplicacao (ver .dockerignore no contexto de build).
COPY server.js middleware.js system-life.js ./
COPY models ./models
COPY views ./views
COPY static ./static

RUN chown -R node:node /app

ENV NODE_ENV=production \
    PORT=8080

USER node

EXPOSE 8080

CMD ["node", "server.js"]
