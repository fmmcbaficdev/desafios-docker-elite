# syntax=docker/dockerfile:1.7
# Produção: só o necessário para rodar a app (sem nodemon, sem shell de dev).

FROM node:22-alpine

LABEL org.opencontainers.image.title="kube-news" \
      org.opencontainers.image.description="Kube News — imagem de produção"

WORKDIR /app

COPY src/package.json src/package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts \
 && npm cache clean --force

COPY src/server.js src/middleware.js src/system-life.js ./
COPY src/models ./models
COPY src/views ./views
COPY src/static ./static

RUN chown -R node:node /app

ENV NODE_ENV=production \
    APP_ENV=production \
    PORT=8080

USER node

EXPOSE 8080

CMD ["node", "server.js"]
