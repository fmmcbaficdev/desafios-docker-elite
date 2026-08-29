# syntax=docker/dockerfile:1.7

# ═══════════════════════════════════════════════════════════════════════
# Rota42 - Video Converter (FFmpeg via convert.sh)
# ═══════════════════════════════════════════════════════════════════════
# O objetivo deste desafio e demonstrar o uso CORRETO de ENTRYPOINT + CMD:
#
#   ENTRYPOINT = comando FIXO (o que o container sempre executa)
#   CMD        = ARGUMENTOS DEFAULT (podem ser sobrescritos ao rodar)
#
# Combinacao:
#   ENTRYPOINT ["/usr/local/bin/convert.sh"]
#   CMD        ["--help"]
#
# Efeitos:
#   docker run rota42/video-converter
#     -> executa: convert.sh --help  (mostra usage, exit 1)
#
#   docker run rota42/video-converter video.mp4 avi
#     -> executa: convert.sh video.mp4 avi  (converte o video)
#
#   docker run --entrypoint sh rota42/video-converter -c "ffmpeg -version"
#     -> ENTRYPOINT tambem pode ser sobrescrito com --entrypoint (raro)
# ═══════════════════════════════════════════════════════════════════════

FROM alpine:3.20

LABEL org.opencontainers.image.title="rota42-video-converter" \
      org.opencontainers.image.description="Converte videos usando ffmpeg via convert.sh" \
      org.opencontainers.image.source="https://github.com/fmmcbaficdev/desafios-docker-elite"

# ffmpeg cobre libx264 e aac (usados pelo convert.sh) via package do Alpine.
# --no-cache evita deixar cache do apk na imagem.
# Nao precisa instalar bash: o script usa /bin/sh (que existe no Alpine).
RUN apk add --no-cache ffmpeg

# Usuario non-root - conversao de video nao precisa de privilegio.
RUN addgroup -S -g 1000 converter \
 && adduser  -S -u 1000 -G converter converter

# Copia o script com permissao de execucao e ownership correto.
COPY --chmod=755 --chown=converter:converter convert.sh /usr/local/bin/convert.sh

# WORKDIR = onde o script procura o arquivo de entrada e escreve a saida.
# Nao ha `chown` explicito - se o usuario der bind mount aqui, o UID do host
# manda; sem bind mount, o /work fica com permissao default (root:root, o=rx).
# Para gravar saidas via bind mount no Windows/Mac, Docker Desktop cuida disso.
WORKDIR /work

USER converter

# ── ENTRYPOINT: fixo, define O QUE o container faz ────────────────────
ENTRYPOINT ["/usr/local/bin/convert.sh"]

# ── CMD: args default, define COMO por padrao ─────────────────────────
# Sem args ao rodar o container, o script sera chamado com "--help".
# Como convert.sh nao reconhece --help como 2 args, ele cai no branch
# de usage e imprime instrucoes de uso. Comportamento default seguro.
CMD ["--help"]
