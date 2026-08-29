# Desafio 01 (trilha 2) — Primeiro Dockerfile

Empacotar a página institucional estática da Rota42 em uma **imagem Docker minimalista** com NGINX, pronta para ser migrada para Kubernetes.

## Missão

- Criar um `Dockerfile` que **copie a página institucional** para uma imagem NGINX
- Otimizar para **menor tamanho possível**
- Criar `compose.yaml` que:
  - Mapeie a porta **8080** do host
  - Permita build via `docker compose build`

## Entrega

```
01-primeiro-dockerfile/
├── Dockerfile
├── compose.yaml
├── .dockerignore
└── site/                Conteúdo estático (index.html, styles.css, images/)
```

## Como usar

```bash
cd desafios-docker-images/01-primeiro-dockerfile

# 1. Buildar a imagem
docker compose build

# 2. Subir o container
docker compose up -d

# 3. Acessar
#    → http://localhost:8080
```

Derrubar:

```bash
docker compose down
```

## Resultado — tamanho da imagem

| Imagem | Tamanho | Redução |
|---|---:|---:|
| `nginx:latest` (Debian) | **238 MB** | referência |
| `nginx:alpine` | 92,7 MB | −61 % |
| **`rota42-institucional:1.0`** | **19,5 MB** | **−91,8 % (12,2× menor)** |

## Decisões de otimização

### 1. `nginx:1.27-alpine-slim` como base

A variante `-alpine-slim` é a menor tag oficial do NGINX. Combinação:

- **Alpine Linux** — musl libc + BusyBox → base ~150 MB menor que a variante Debian
- **-slim** — remove módulos que só servem em cenários dinâmicos (`mail`, `xslt`, `image-filter`, `geoip`), mantendo o suficiente para conteúdo estático
- **Tag pinada (`1.27`)** — build reprodutível (não pega uma versão nova sem querer)

### 2. Nenhum `RUN` extra

A imagem base já traz o `nginx.conf` default apontando para `/usr/share/nginx/html` na porta 80. Como o conteúdo é 100% estático, **não precisamos** de:

- Instalar pacotes adicionais
- Ajustar configs
- Rodar scripts

Menos layers = imagem menor, build mais rápido, menor superfície de ataque.

### 3. `COPY` direto do diretório final

```dockerfile
COPY site/ /usr/share/nginx/html/
```

Copia apenas o **conteúdo** de `site/`, não o diretório em si. Resultado: `index.html` fica direto em `/usr/share/nginx/html/index.html` — que é onde o NGINX default procura.

### 4. `.dockerignore` com whitelist

Estratégia inversa: **ignora tudo**, aceita explicitamente só o que precisa:

```
*
!site/
!site/**
!Dockerfile
```

Vantagens:

- Não vaza `README.md`, `DESAFIO.md`, `.git`, arquivos de editor, etc.
- Reduz o **build context** enviado ao daemon (mais rápido em CI e em conexões remotas)
- Seguro por padrão — adicionar um arquivo local não altera silenciosamente a imagem

## Anatomia do `compose.yaml`

```yaml
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    image: rota42-institucional:1.0     # nome/tag da imagem gerada
    container_name: rota42-institucional
    pull_policy: build                   # prefere build local sobre pull
    ports:
      - "8080:80"                        # host:container
```

- `build:` — habilita `docker compose build`
- `image:` — define nome e tag da imagem produzida (usável fora do compose)
- `pull_policy: build` — evita ir no registry se já tiver a imagem local

## Validação realizada

```bash
$ docker compose build
✔  rota42-institucional:1.0  Built

$ docker compose up -d
✔  Container rota42-institucional  Started

$ curl -sI http://localhost:8080 | head -1
HTTP/1.1 200 OK

$ curl -s http://localhost:8080 | grep -o '<title>.*</title>'
<title>Rota42 - Gerenciamento de Containers Inteligente</title>

$ curl -sI http://localhost:8080/images/logo.png | grep -E 'HTTP|Content-Type'
HTTP/1.1 200 OK
Content-Type: image/png

$ docker images rota42-institucional:1.0
REPOSITORY                TAG    SIZE
rota42-institucional      1.0    19.5MB
```

## Próximos passos naturais

Este é o "hello world" de imagens Docker. Refinamentos que virão em desafios futuros:

- **Multi-stage builds** — separar etapa de build (npm/pip) da etapa runtime
- **Distroless / `FROM scratch`** — imagens ainda menores (~5 MB) para binários compilados
- **Non-root user** — rodar NGINX sem privilégios
- **Healthcheck** — `HEALTHCHECK` para orquestradores saberem quando reiniciar
- **Cache mount** — `RUN --mount=type=cache` para acelerar rebuilds
- **BuildKit / SBOM / attestations** — supply-chain security
