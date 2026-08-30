# Desafios Docker — Elite

Coletânea de desafios práticos de Docker e Docker Compose, resolvidos passo a passo, organizada em trilhas.

## Estrutura

```
desafios-docker-fundamentals/    Trilha 1 — fundamentos (containers, volumes, compose)
├── 01-primeiro-container/       Ciclo básico: pull, run, ps, stop, rm
├── 02-container-logs/           Persistência de logs de Nginx via volume
├── 03-blog/                     WordPress + MySQL com persistência (Docker Compose)
├── 04-ambiente/                 PostgreSQL + pgAdmin para app NodeJS local
├── 05-analise-logs/             Diagnóstico e correção de compose quebrado (via logs)
└── 06-multiplos-ambientes/      Dev + Homolog isolados via múltiplos arquivos .env

desafios-docker-images/          Trilha 2 — imagens (Dockerfile, build, otimização, registry)
├── 01-primeiro-dockerfile/      Página estática em NGINX + Docker Compose build
├── 02-boas-praticas-dockerfile/ Refatoração de Dockerfile FastAPI (multi-stage, cache, non-root)
├── 03-entrypoint-vs-cmd/        Container FFmpeg com args dinâmicos (ENTRYPOINT + CMD)
└── 04-multistage-build/         Conversor Go + ffmpeg em multi-stage (sem SDK na imagem final)

desafios-docker-security/        Trilha 3 — segurança (scan, hardening, SBOM, distroless, Cosign)
├── 01-identificando-vulnerabilidades/
├── 02-imagem-docker-segura/
├── 03-sbom-docker-scout/
├── 04-distroless-e-cosign/
├── 05-identificando-vulnerabilidades-fake-shop/
├── 06-imagem-docker-segura-fake-shop/
├── 07-sbom-trivy-fake-shop/
└── 08-distroless-e-cosign-fake-shop/

desafios-docker-devcontainers/    Trilha 4 — DevContainers (ambiente reprodutível no VS Code)
├── kube-news/                   Produção + .devcontainer (Node.js)
└── fake-shop/                   Produção + .devcontainer (Python)
```

## Trilha 1 — Fundamentos

| # | Desafio | Tecnologias | Entrega |
|---|---|---|---|
| 01 | [Primeiro Container](desafios-docker-fundamentals/01-primeiro-container/) | Docker CLI, Nginx | `run_containers.sh` |
| 02 | [Container Logs](desafios-docker-fundamentals/02-container-logs/) | Docker Volumes, Nginx | `nginx_volume_container.sh` |
| 03 | [Blog Rota42](desafios-docker-fundamentals/03-blog/) | Docker Compose, WordPress, MySQL | `compose.yaml` |
| 04 | [Ambiente kube-news](desafios-docker-fundamentals/04-ambiente/) | Docker Compose, PostgreSQL, pgAdmin | `compose.yaml` |
| 05 | [Análise de Logs](desafios-docker-fundamentals/05-analise-logs/) | Docker Compose, Flask, PostgreSQL, troubleshooting | `compose.yaml` |
| 06 | [Múltiplos Ambientes](desafios-docker-fundamentals/06-multiplos-ambientes/) | Docker Compose, `--env-file`, isolamento | `compose.yaml`, `.dev.env`, `.homolog.env` |

## Trilha 2 — Imagens

Foco em construção, otimização e distribuição de imagens: `Dockerfile`, multi-stage builds, `.dockerignore`, redução de tamanho, tags/versionamento e registries.

| # | Desafio | Tecnologias | Entrega |
|---|---|---|---|
| 01 | [Primeiro Dockerfile](desafios-docker-images/01-primeiro-dockerfile/) | Dockerfile, `nginx:alpine-slim`, Docker Compose (build) | `Dockerfile`, `compose.yaml` |
| 02 | [Boas Práticas de Dockerfile](desafios-docker-images/02-boas-praticas-dockerfile/) | Multi-stage, BuildKit cache, non-root, HEALTHCHECK, FastAPI | `Dockerfile`, `compose.yaml` |
| 03 | [ENTRYPOINT vs CMD](desafios-docker-images/03-entrypoint-vs-cmd/) | ENTRYPOINT exec form, CMD default, ffmpeg, Alpine, compose profiles | `Dockerfile`, `compose.yaml`, `convert.sh` |
| 04 | [Multistage Build](desafios-docker-images/04-multistage-build/) | Go, multi-stage, Alpine + ffmpeg, binário estático | `Dockerfile`, `compose.yaml` |

## Trilha 3 — Segurança

Revisão da cadeia de suprimentos de imagens Docker da Rota42, aplicada em duas apps: **Kube News** (Node.js) e **Fake Shop** (Python). Ciclo: identificar CVEs → endurecer o Dockerfile → gerar SBOM → assinar imagem distroless.

| # | Desafio | Tecnologias | Entrega |
|---|---|---|---|
| 01 | [Identificando vulnerabilidades](desafios-docker-security/01-identificando-vulnerabilidades/) | Docker Scout, SARIF, npm (Kube News) | `vulnerabilities-report.sarif` |
| 02 | [Imagem Docker segura](desafios-docker-security/02-imagem-docker-segura/) | Scout, Hadolint, Alpine, non-root, npm ci | `Dockerfile`, SARIF before/after, `hadolint-report.txt` |
| 03 | [SBOM Docker Scout](desafios-docker-security/03-sbom-docker-scout/) | Docker Scout SBOM JSON (Kube News) | `sbom-report.json` |
| 04 | [Distroless e Cosign](desafios-docker-security/04-distroless-e-cosign/) | Chainguard Distroless, Cosign, Docker Hub | `Dockerfile`, `cosign-signature.txt` |
| 05 | [Identificando vulnerabilidades](desafios-docker-security/05-identificando-vulnerabilidades-fake-shop/) | Trivy, SARIF, pip (Fake Shop) | `vulnerabilities-report.sarif` |
| 06 | [Imagem Docker segura](desafios-docker-security/06-imagem-docker-segura-fake-shop/) | Trivy, Hadolint, Alpine, non-root, pip (Fake Shop) | `Dockerfile`, SARIF before/after, `hadolint-report.txt` |
| 07 | [SBOM com Trivy](desafios-docker-security/07-sbom-trivy-fake-shop/) | Trivy CycloneDX JSON (Fake Shop) | `sbom-report.json` |
| 08 | [Distroless e Cosign](desafios-docker-security/08-distroless-e-cosign-fake-shop/) | Chainguard Distroless, Cosign, Docker Hub (Fake Shop) | `Dockerfile`, `cosign-signature.txt` |

## Trilha 4 — DevContainers

Ambiente de desenvolvimento padronizado com DevContainers no VS Code, nos mesmos pilotos da trilha 3: **Kube News** e **Fake Shop**. Produção (`Dockerfile` + `compose.yml`) fica na raiz de cada piloto; o DevContainer fica em `.devcontainer/`.

| # | Desafio | Tecnologias | Entrega |
|---|---|---|---|
| 01 | [DevContainer Kube News](desafios-docker-devcontainers/kube-news/) | DevContainer, Compose, Node.js, PostgreSQL | `.devcontainer/` no [fork](https://github.com/fmmcbaficdev/kube-news) |
| 02 | [Extensões e volumes](desafios-docker-devcontainers/kube-news/) | REST Client, ESLint, Docker, volume Postgres, `npm install` | mesmo `.devcontainer/` do fork |

## Pré-requisitos

- **Docker Desktop** rodando (Windows/Mac) ou **Docker Engine** (Linux)
- **Git Bash** ou **WSL** para executar scripts `.sh` no Windows
- Ports livres no host — cada desafio documenta as portas usadas

## Como usar

Cada desafio é auto-contido. Entre no diretório correspondente e siga o `README.md` local:

```bash
cd desafios-docker-fundamentals/01-primeiro-container
./run_containers.sh
```

ou (Docker Compose):

```bash
cd desafios-docker-fundamentals/03-blog
cp .env.example .env
docker compose up -d
```

## Convenções

- Scripts em Bash com `set -euo pipefail`
- Line endings **LF** forçados via `.gitattributes` (evita erros de CRLF em containers)
- Credenciais em `.env` (nunca commitadas) — templates em `.env.example`
- Volumes nomeados para persistência (nunca dependemos da camada de escrita do container)

## Licença

Uso educacional livre.
