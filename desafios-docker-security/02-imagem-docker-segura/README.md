# Desafio 02 (trilha 3) — Imagem Docker segura (Kube News)

As dependências npm já foram atualizadas. Este desafio endurece a **imagem Docker**: scan da imagem original, Hadolint no Dockerfile antigo, refatoração e scan da imagem nova.

## Entrega

```
02-imagem-docker-segura/
├── Dockerfile                 ← endurecido
├── Dockerfile.original        ← o da equipe (referência)
├── package.json               ← deps corrigidas (enunciado)
├── before-fix-report.sarif    ← Scout da imagem original
├── hadolint-report.txt        ← análise do Dockerfile antigo
└── after-fix-report.sarif     ← Scout da imagem corrigida
```

## Resultados

| | Antes (`kube-news:before`) | Depois (`kube-news:after`) |
|---|---:|---:|
| Base | `node:23.9.0` (Debian) | `node:23.9.0-alpine` |
| Tamanho | **1,68 GB** | **325 MB** (−81 %) |
| Pacotes indexados | 876 | 342 |
| Pacotes vulneráveis | 86 | 23 |
| CVEs (Scout) | **776** | **61** (−92 %) |
| CRITICAL | 11 | 2 |
| HIGH | 178 | 32 |
| Usuário | root | `node` (UID 1000) |

As 61 CVEs restantes vêm sobretudo da base Alpine/Node e de deps npm sem patch total — o ciclo 04 (distroless) reduz ainda mais a base OS.

## O que mudou no Dockerfile

| Antes | Depois |
|---|---|
| `FROM node:23.9.0` | `FROM node:23.9.0-alpine` |
| `npm install` | `npm ci --omit=dev` + `npm cache clean` |
| `COPY . .` | COPY explícito do código da app |
| root | `USER node` |
| — | `NODE_ENV=production` |

## Como reproduzir

```bash
# contexto: kube-news/src (package.json já atualizado + npm install)

# 1. Imagem original
docker build -f Dockerfile.original -t kube-news:before .
docker scout cves --format sarif --output before-fix-report.sarif kube-news:before

# 2. Hadolint
docker run --rm -v "$PWD:/work" hadolint/hadolint \
  hadolint /work/Dockerfile.original | tee hadolint-report.txt

# 3. Imagem corrigida
docker build -t kube-news:after .
docker scout cves --format sarif --output after-fix-report.sarif kube-news:after
```
