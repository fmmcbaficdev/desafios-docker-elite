# Desafios 01–02 (trilha 4) — DevContainer do Kube News

Entrega oficial: fork do [KubeDev/kube-news](https://github.com/KubeDev/kube-news) com o DevContainer na raiz do projeto.

**Fork:** https://github.com/fmmcbaficdev/kube-news

```
kube-news/
└── .devcontainer/
    ├── devcontainer.json    # extensões + postCreateCommand (npm install)
    ├── Dockerfile
    └── docker-compose.yml   # Postgres com volume persistente
```

## O que o desafio 02 adiciona

| Item | Onde | Detalhe |
|---|---|---|
| REST Client | `humao.rest-client` | Testar APIs (`popula-dados.http`) |
| ESLint | `dbaeumer.vscode-eslint` | Padronização JavaScript (`src/`) |
| Docker | `ms-azuretools.vscode-docker` | Integração Docker no VS Code |
| Volume persistente | `kube-news-dev-postgres` | Dados do Postgres sobrevivem a Rebuild/down |
| `postCreateCommand` | `cd src && npm install` | Dependências na criação do ambiente |

## Como abrir no VS Code

1. Clone o fork e abra **a pasta `kube-news`** (não o monorepo elite).
2. Instale a extensão [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
3. `Dev Containers: Rebuild and Reopen in Container`.
4. Espere o `postCreateCommand` (`npm install` em `src/`).
5. Confira as extensões: REST Client, ESLint, Docker.
6. No terminal do container: `cd src && npm start`.
7. App em http://localhost:8080 (encaminhada pelo VS Code; a 8080 do host já é usada pelo `rota42-institucional`).

Credenciais (defaults do README do Kube News): usuário/banco `kubedevnews`, senha `Pg#123`.

Para apagar o banco de verdade: `docker volume rm kube-news-dev-postgres`.
