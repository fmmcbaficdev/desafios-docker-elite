# Desafio 02 (trilha 2) — Boas Práticas de Dockerfile

O boilerplate FastAPI da Rota42 sofria com **build lento, imagem gigante e execução como root**. Este desafio refatora o `Dockerfile` aplicando boas práticas e entrega um `compose.yaml` que facilita executar, buildar e publicar (`push`) a imagem.

## Missão

- Refatorar o `Dockerfile` aplicando boas práticas
- Adicionar `compose.yaml` que facilite:
  - **Execução** da aplicação
  - **Build** da imagem
  - **Push** da imagem para um registry

## Entrega

```
02-boas-praticas-dockerfile/
├── Dockerfile               ← multi-stage otimizado
├── Dockerfile.original      ← boilerplate original (para referência)
├── compose.yaml             ← up + build + push
├── .env.example             ← template para configurar registry
├── .dockerignore            ← whitelist
├── app.py
└── requirements.txt
```

## Resultados mensurados

Executado no boilerplate fornecido pela equipe:

| Métrica | Original (com pin mínimo) | Otimizado | Ganho |
|---|---:|---:|---:|
| **Tamanho da imagem** | 1,72 GB | **283 MB** | **−83,5 % (6× menor)** |
| **Build inicial** | 26 s | 32 s | −6 s (aceitável) |
| **Rebuild após mudar código** | 22,4 s | **5,2 s** | **4,3× mais rápido** |
| **Usuário do processo** | root (uid 0) | app (uid 1000) | non-root |
| **Health status** | (não configurado) | healthy | orquestrador consciente |

> **Observação importante**: o Dockerfile original **AS-IS não builda** — porque `FROM python` (sem tag) pega a versão mais recente do Python (3.14 no momento do teste), e várias dependências (`pydantic_core`, `watchfiles`) ainda não têm wheels pré-compilados para essa versão. Precisou fallback para compilar em Rust e falhou. A comparação acima usa `FROM python:3.12` como baseline "mínima" — sem essa correção o build simplesmente não conclui, o que já é a primeira lição do desafio.

## Como usar

### 1. Executar

```bash
cd desafios-docker-images/02-boas-praticas-dockerfile

docker compose up -d
curl http://localhost:8000/
# → {"message":"Hello, FastAPI with Docker!"}
```

### 2. Buildar

```bash
docker compose build
```

Produz a imagem com o nome/tag definidos em `IMAGE_REPO:IMAGE_TAG` (ver `.env.example`). Default: `rota42/fastapi-boilerplate:1.0`.

### 3. Publicar em um registry

```bash
cp .env.example .env
# Editar .env e apontar IMAGE_REPO para seu registry

docker login docker.io          # ou ghcr.io / seu-acr / ecr / etc
docker compose build
docker compose push
```

### 4. Derrubar

```bash
docker compose down
```

## Boas práticas aplicadas — o que mudou e por quê

### 1. Multi-stage build

**Antes**: um único estágio — a imagem final carrega toolchain do pip, cache, headers de compilação, tudo.

**Depois**: dois estágios. O `builder` instala deps num `virtualenv`; o `runtime` copia só o `venv` pronto. Zero build tools na imagem final.

```dockerfile
FROM python:3.12-slim-bookworm AS builder
# ... instala deps num venv ...

FROM python:3.12-slim-bookworm
COPY --from=builder /opt/venv /opt/venv
```

### 2. Tag pinada (`python:3.12-slim-bookworm`)

**Antes**: `FROM python` — pega o `:latest`. Build de hoje é diferente do de amanhã. **Nesse caso específico, quebrou completamente o build** (Python 3.14 sem wheels).

**Depois**: versão explícita do Python **e do distro** — build reprodutível.

### 3. Variante `-slim`

**Antes**: `python` (Debian full) → base ~1 GB.

**Depois**: `python:3.12-slim-bookworm` → base ~50 MB. Remove ferramentas Unix que a app não usa.

### 4. Ordem cache-friendly

O Docker cacheia camadas em ordem. Se uma camada muda, TODAS as seguintes são reconstruídas.

**Antes**:
```dockerfile
COPY . .                              # muda a cada alteração no código
RUN pip install -r requirements.txt   # → reinstala TUDO sempre
```

**Depois**:
```dockerfile
COPY requirements.txt .               # muda raramente
RUN pip install -r requirements.txt   # → cacheado
COPY app.py .                         # muda frequentemente, mas só invalida a última camada
```

Resultado: rebuild após mudança de código passou de **22,4 s → 5,2 s** (4,3× mais rápido).

### 5. `--mount=type=cache` no `pip`

BuildKit permite montar caches persistentes:

```dockerfile
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

O cache do pip **persiste entre builds** sem ficar dentro da imagem. Rebuilds que precisem reinstalar deps aproveitam wheels já baixados.

### 6. Non-root user

**Antes**: processo rodava como `root` (uid 0). Padrão inseguro — se a app for comprometida, o atacante tem root dentro do container.

**Depois**:

```dockerfile
RUN addgroup --system --gid 1000 app && \
    adduser  --system --uid 1000 --ingroup app app
USER app
```

Container roda como `uid 1000`. Verificável:

```bash
$ docker exec rota42-fastapi id
uid=1000(app) gid=1000(app) groups=1000(app)
```

### 7. Variáveis de ambiente Python

```dockerfile
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
```

- `PYTHONDONTWRITEBYTECODE=1` — não gera `.pyc` no filesystem do container (imagem menor + rootfs limpo)
- `PYTHONUNBUFFERED=1` — logs sai em tempo real para stdout/stderr (essencial para `docker logs` e para observabilidade em produção)

### 8. `HEALTHCHECK`

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://localhost:8000/').status==200 else 1)"
```

Sem instalar `curl` ou `wget` — usa a stdlib. Docker sabe reportar `healthy`/`unhealthy`, o que orquestradores podem usar para restart automático ou remoção de load balancer.

### 9. `.dockerignore` com whitelist

**Antes**: sem `.dockerignore` — `COPY . .` copiava `__pycache__`, `.git`, `.venv`, arquivos de IDE, secrets locais…

**Depois**: whitelist explícita — só `app.py`, `requirements.txt` e o `Dockerfile` entram no build context.

## Anatomia do `compose.yaml`

Três operações num único arquivo:

```yaml
services:
  api:
    build:                            # docker compose build
      context: .
      dockerfile: Dockerfile
    image: ${IMAGE_REPO:-rota42/fastapi-boilerplate}:${IMAGE_TAG:-1.0}
                                       # docker compose push usa esta tag
    container_name: rota42-fastapi
    pull_policy: build                 # prefere build local
    ports:
      - "${APP_PORT:-8000}:8000"       # docker compose up
    healthcheck: ...
```

`IMAGE_REPO` no `.env` aponta para o registry alvo (Docker Hub, GHCR, ECR, ACR, self-hosted, etc). O mesmo `docker compose push` funciona pra qualquer um deles.

## Cheat sheet

```bash
# Executar (constrói se necessário):
docker compose up -d

# Testar:
curl http://localhost:8000/

# Ver status de saúde:
docker compose ps
# STATUS: Up (healthy)

# Rebuild forçado sem cache:
docker compose build --no-cache

# Ver o comando de push que seria executado:
docker compose config | grep image:

# Publicar (após docker login):
docker compose push

# Logs em tempo real:
docker compose logs -f api

# Derrubar:
docker compose down
```

## Referência: os 3 arquivos-chave

- [`Dockerfile`](Dockerfile) — versão refatorada (multi-stage, 9 boas práticas)
- [`Dockerfile.original`](Dockerfile.original) — versão original **exatamente como recebida** (não builda hoje)
- [`compose.yaml`](compose.yaml) — build + run + push num arquivo só
