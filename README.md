# Desafios Docker — Elite

Coletânea de desafios práticos de Docker e Docker Compose, resolvidos passo a passo.

## Estrutura

```
desafios-docker-fundamentals/
├── 01-primeiro-container/    Ciclo básico: pull, run, ps, stop, rm
├── 02-container-logs/        Persistência de logs de Nginx via volume
├── 03-blog/                  WordPress + MySQL com persistência (Docker Compose)
└── 04-ambiente/              PostgreSQL + pgAdmin para app NodeJS local
```

## Índice de desafios

| # | Desafio | Tecnologias | Entrega |
|---|---|---|---|
| 01 | [Primeiro Container](desafios-docker-fundamentals/01-primeiro-container/) | Docker CLI, Nginx | `run_containers.sh` |
| 02 | [Container Logs](desafios-docker-fundamentals/02-container-logs/) | Docker Volumes, Nginx | `nginx_volume_container.sh` |
| 03 | [Blog Rota42](desafios-docker-fundamentals/03-blog/) | Docker Compose, WordPress, MySQL | `compose.yaml` |
| 04 | [Ambiente kube-news](desafios-docker-fundamentals/04-ambiente/) | Docker Compose, PostgreSQL, pgAdmin | `compose.yaml` |

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
