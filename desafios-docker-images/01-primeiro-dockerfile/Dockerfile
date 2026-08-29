# syntax=docker/dockerfile:1.7

# ─────────────────────────────────────────────────────────────────────
# Rota42 - pagina institucional
# ─────────────────────────────────────────────────────────────────────
# Imagem base: nginx:1.27-alpine-slim.
# Escolha justificada:
#   - Alpine   -> ~150MB menor que a variante Debian (musl + busybox)
#   - -slim    -> remove modulos que so servem em cenarios dinamicos
#                 (mail, xslt, image-filter, geoip), mantendo o suficiente
#                 para servir conteudo estatico.
#   - Tag pinada (1.27) para reprodutibilidade do build.
# Resultado tipico: imagem final ~25MB (vs ~200MB do nginx:latest).
# ─────────────────────────────────────────────────────────────────────

FROM nginx:1.27-alpine-slim

LABEL org.opencontainers.image.title="rota42-institucional" \
      org.opencontainers.image.description="Pagina institucional da Rota42 servida por NGINX" \
      org.opencontainers.image.source="https://github.com/fmmcbaficdev/desafios-docker-elite"

# Copia direto no diretorio default do nginx - nenhum RUN extra necessario.
# A imagem base ja traz um nginx.conf que serve /usr/share/nginx/html na porta 80.
COPY site/ /usr/share/nginx/html/

EXPOSE 80
