# Desafio 04 (trilha 4) — DevContainer e produção do Fake Shop

Entrega oficial: [fork](https://github.com/fmmcbaficdev/fake-shop)

```
fake-shop/
├── .devcontainer/
│   ├── devcontainer.json              # Python, REST Client, Docker
│   ├── Dockerfile.dev                 # Flask debug + debugpy
│   └── docker-compose.override.yml
├── compose.yml                        # produção
├── Dockerfile                         # Alpine, non-root, gunicorn
└── README.md
```

| | Produção | DevContainer |
|---|---|---|
| Compose | só `compose.yml` | `compose.yml` + override |
| Env | `FLASK_ENV=production` | `FLASK_ENV=development` / `FLASK_DEBUG=1` |
| Volume | `fake-shop-prod-postgres` | `fake-shop-dev-postgres` |

## Produção

No clone/fork (precisa de `src/`):

```bash
docker compose -f compose.yml up -d --build
```

http://localhost:5002 (5000/5001 já são outros stacks).

## DevContainer

Abra a pasta `fake-shop` → **Rebuild and Reopen in Container**, depois:

```bash
cd src && flask run --host=0.0.0.0 --port=5000 --debug
```
