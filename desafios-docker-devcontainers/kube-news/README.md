# Desafios 01–03 (trilha 4) — DevContainer e produção do Kube News

Entrega oficial: [fork](https://github.com/fmmcbaficdev/kube-news) (os arquivos abaixo são o espelho).

```
kube-news/
├── .devcontainer/
│   ├── devcontainer.json
│   ├── Dockerfile.dev                 # nodemon (hot reload)
│   └── docker-compose.override.yml    # ajustes de desenvolvimento
├── compose.yml                        # produção
├── Dockerfile                         # produção (Alpine, non-root)
└── README.md
```

| Variável | Produção | DevContainer |
|---|---|---|
| `NODE_ENV` / `APP_ENV` | `production` | `development` |
| Imagem | `Dockerfile` Alpine | `Dockerfile.dev` + nodemon |
| Compose | só `compose.yml` | `compose.yml` + override |
| Volume Postgres | `kube-news-prod-postgres` | `kube-news-dev-postgres` |

## Produção

No clone/fork do **kube-news** (precisa da pasta `src/`):

```bash
docker compose -f compose.yml up -d --build
```

http://localhost:8088 (a 8080 do host já é do `rota42-institucional`). Outra porta: `APP_PORT=8099 docker compose -f compose.yml up -d --build`

```bash
docker compose -f compose.yml down
```

## DevContainer

Abra a pasta `kube-news` no VS Code → **Rebuild and Reopen in Container**. Depois:

```bash
cd src && nodemon server.js
```
