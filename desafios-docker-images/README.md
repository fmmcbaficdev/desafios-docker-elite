# Desafios Docker — Imagens

Segunda trilha da coletânea. Foco em **construção, otimização e distribuição de imagens Docker**: `Dockerfile`, multi-stage builds, tags e versionamento, `.dockerignore`, redução de tamanho, layers, cache, e publicação em registries.

## Índice de desafios

| # | Desafio | Tecnologias | Entrega |
|---|---|---|---|
| 01 | [Primeiro Dockerfile](01-primeiro-dockerfile/) | Dockerfile, `nginx:alpine-slim`, Docker Compose (build) | `Dockerfile`, `compose.yaml` |
| 02 | [Boas Práticas de Dockerfile](02-boas-praticas-dockerfile/) | Multi-stage, BuildKit cache mount, non-root, HEALTHCHECK, Python/FastAPI | `Dockerfile`, `compose.yaml` |
| 03 | [ENTRYPOINT vs CMD](03-entrypoint-vs-cmd/) | ENTRYPOINT exec form, CMD default, ffmpeg, Alpine, profiles do Compose | `Dockerfile`, `compose.yaml`, `convert.sh` |
| 04 | [Multistage Build](04-multistage-build/) | Go, multi-stage, Alpine + ffmpeg, binário estático | `Dockerfile`, `compose.yaml` |

## Convenções da trilha

- Cada desafio vive em uma pasta numerada (`01-`, `02-`, …) com nome descritivo
- Entrega principal: `Dockerfile` (+ `.dockerignore`, `compose.yaml` quando aplicável)
- Cada pasta traz um `README.md` público com: missão, decisões técnicas, como buildar/rodar e como validar
- `DESAFIO.md` (local, não versionado) guarda análise técnica detalhada
- Line endings **LF** forçados via `.gitattributes` da raiz do repo
