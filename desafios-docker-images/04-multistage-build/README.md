# Desafio 04 (trilha 2) — Multistage Build

O conversor de vídeos da Rota42 migrou de Shell para **Go**. O Dockerfile naive da equipe compilava e rodava no mesmo stage — a imagem final carregava o **SDK Go + ffmpeg + Debian**. Este desafio refatora isso com **multi-stage build**: o toolchain fica só no builder; o runtime leva apenas o binário estático e o ffmpeg.

## Missão

- Dockerfile com **Multistage Build**, imagem a menor possível, funcionalidade completa
- Container aceita **parâmetros dinâmicos** (arquivo + formato)
- `compose.yaml` que constrói e facilita a execução

## Entrega

```
04-multistage-build/
├── Dockerfile               ← multi-stage (entrega)
├── Dockerfile.original      ← naive da equipe (referência)
├── compose.yaml
├── converter.go             ← porta do convert.sh em Go (só stdlib)
├── go.mod
├── .dockerignore
└── videos/                  ← bind mount → /work
```

> `go.sum` não existe: o módulo **não tem dependências de terceiros**. `go mod tidy` não gera entradas.

## Resultados mensurados

| Imagem | Tamanho | Build |
|---|---:|---:|
| Naive (`golang:1.23` + apt ffmpeg) | **2,13 GB** | 169 s |
| **Multi-stage** (`alpine` + ffmpeg + binário) | **191 MB** | 22 s |
| Ganho | **−91 % (11× menor)** | 7,6× mais rápido no 1º build |

O runtime do desafio 03 (só ffmpeg no Alpine) tinha 189 MB. Aqui o binário Go adiciona ~2 MB — o toolchain de ~800 MB **não entra** na imagem final.

## Como o multi-stage funciona

```
┌─────────────────────────┐     COPY --from=builder
│  Stage builder          │ ──────────────────────────┐
│  golang:1.23-alpine     │                           ▼
│  go build → /out/conv   │              ┌─────────────────────────┐
└─────────────────────────┘              │  Stage runtime          │
         ▲ descartado                    │  alpine:3.20 + ffmpeg   │
                                         │  + binário (~2 MB)      │
                                         └─────────────────────────┘
```

```dockerfile
FROM golang:1.23-alpine AS builder
# ... go build -ldflags="-s -w" -o /out/converter .

FROM alpine:3.20
RUN apk add --no-cache ffmpeg
COPY --from=builder /out/converter /usr/local/bin/converter
```

O stage `builder` some da imagem publicada. Só o que o `COPY --from` puxa sobrevive.

## Por que não dá para ir a `scratch` / distroless

O conversor **chama `ffmpeg` em runtime**. `FROM scratch` exigiria empacotar ffmpeg + dezenas de `.so` à mão. Alpine + `apk add ffmpeg` é o menor caminho oficial que mantém `libx264` e `aac`.

O ganho do desafio não é “zerar o Alpine”; é **não levar o compilador Go para produção**.

## Decisões do builder

| Prática | Efeito |
|---|---|
| `golang:1.23-alpine` | Builder menor e mais rápido de puxar que `golang:1.23` (Debian) |
| `COPY go.mod` antes do código | Cache de deps se só `converter.go` mudar |
| `CGO_ENABLED=0` | Binário estático, sem libc do builder |
| `-ldflags="-s -w"` | Remove símbolos/DWARF |
| `--mount=type=cache` (mod + build) | Rebuilds reaproveitam cache do Go sem inflar a imagem |

## ENTRYPOINT + CMD (mesmo contrato do desafio 03)

```dockerfile
ENTRYPOINT ["/usr/local/bin/converter"]
CMD ["--help"]
```

| Comando | Resultado |
|---|---|
| `docker compose run --rm converter` | usage (CMD default) |
| `docker compose run --rm converter video.mp4 avi` | converte |

## Como usar

```bash
cd desafios-docker-images/04-multistage-build
docker compose build

# Sem args → usage
docker compose run --rm converter

# Com vídeo em ./videos/
docker compose run --rm converter video.mp4 avi
docker compose --profile examples run --rm mp4-para-mkv
```

Sem vídeo de teste (gera 2 s no próprio container):

```bash
docker compose run --rm --entrypoint ffmpeg converter \
  -f lavfi -i "testsrc=duration=2:size=320x240:rate=15" \
  -f lavfi -i "sine=frequency=440:duration=2" \
  -c:v libx264 -c:a aac -shortest -y video.mp4
```

## Validação realizada

- Usage default + exit 1 ✅
- `uid=1000(converter)` ✅
- MP4 → AVI (`videos/output.avi`, 42 KB) ✅
- Imagem final **191 MB** vs naive **2,13 GB** ✅
