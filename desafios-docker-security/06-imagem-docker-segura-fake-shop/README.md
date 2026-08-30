# Desafio 06 (trilha 3) — Imagem Docker segura (Fake Shop)

As dependências pip já foram atualizadas no enunciado. Este desafio endurece a **imagem Docker**: scan da imagem original, Hadolint no Dockerfile antigo, refatoração e scan da imagem nova — tudo com **Trivy**.

## Entrega

```
06-imagem-docker-segura-fake-shop/
├── Dockerfile                 ← endurecido
├── Dockerfile.original        ← o da equipe (referência)
├── requirements.txt           ← deps corrigidas (enunciado)
├── before-fix-report.sarif    ← Trivy da imagem original
├── hadolint-report.txt        ← análise do Dockerfile antigo
└── after-fix-report.sarif     ← Trivy da imagem corrigida
```

## Resultados

| | Antes (`fake-shop:before`) | Depois (`fake-shop:after`) |
|---|---:|---:|
| Base | `python:3.11` (Debian 13) | `python:3.11-alpine` (multi-stage) |
| Tamanho | **1,68 GB** | **187 MB** (−89 %) |
| Findings SARIF | **2921** | **63** (−98 %) |
| CRITICAL | 56 | **0** |
| HIGH | 388 | 29 |
| MEDIUM | 982 | 20 |
| LOW | 1272 | 14 |
| UNKNOWN | 223 | 0 |
| Usuário | root | UID **1000** |

Os 63 findings restantes: ~20 Alpine, toolchain da imagem `python` (pip/setuptools) e pins do enunciado que ainda têm CVE (**GitPython 3.1.41**, Mako 1.3.5, Werkzeug 3.0.6, Flask 3.0.0). O ciclo 08 (distroless) reduz a base OS.

## O que mudou no Dockerfile

| Antes | Depois |
|---|---|
| `FROM python:3.11` | multi-stage `python:3.11-alpine` |
| `pip install` (cache na camada, root) | venv no builder + `PIP_NO_CACHE_DIR` |
| `COPY . .` | COPY explícito (models, templates, static, migrations) |
| root | `USER 1000` (`appuser`) |
| `gunicorn ... app:app` | `index:app` (modulo Flask real) |
| — | `libpq` + `psycopg[binary]` no Alpine (ctypes/musl não acha `.so.5`); gcc só no builder |

Hadolint 2.15.1 no original: **DL3042** (pip sem `--no-cache-dir`). No Dockerfile novo: **exit 0**.

## Como reproduzir

Contexto: `fake-shop/src` (requirements do enunciado + `.dockerignore` excluindo `.venv`).

```bash
# 1. Imagem original
docker build -f Dockerfile.original -t fake-shop:before .
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD:/out" aquasec/trivy:latest image \
  --scanners vuln --format sarif --output /out/before-fix-report.sarif \
  fake-shop:before

# 2. Hadolint
docker run --rm -v "$PWD:/work" hadolint/hadolint \
  hadolint --format json /work/Dockerfile.original | tee hadolint-report.txt

# 3. Imagem corrigida
docker build -t fake-shop:after .
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD:/out" aquasec/trivy:latest image \
  --scanners vuln --format sarif --output /out/after-fix-report.sarif \
  fake-shop:after
```

No Git Bash, prefixe `docker run` com `MSYS_NO_PATHCONV=1` (o MSYS reescreve `/out` e `/work`).
