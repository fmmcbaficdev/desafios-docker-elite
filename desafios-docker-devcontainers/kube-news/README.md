# Desafio 01 (trilha 4) — DevContainer do Kube News

Entrega oficial: fork do [KubeDev/kube-news](https://github.com/KubeDev/kube-news) com o DevContainer na raiz do projeto.

**Fork:** https://github.com/fmmcbaficdev/kube-news

```
kube-news/
└── .devcontainer/
    ├── devcontainer.json
    ├── Dockerfile
    └── docker-compose.yml
```

A cópia nesta pasta é o mesmo `.devcontainer/` do fork (o clone `kube-news/` na raiz deste repo é gitignored).

## Como abrir no VS Code

1. Clone o fork e abra **a pasta `kube-news`** (não o monorepo elite).
2. Instale a extensão [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
3. `Dev Containers: Reopen in Container`.
4. O `postCreateCommand` roda `npm install` em `src/`.
5. No terminal do container: `cd src && npm start`.
6. App em http://localhost:8080 (encaminhada pelo VS Code, não publicada no Compose — a 8080 do host já é usada pelo `rota42-institucional`). Postgres no serviço `db` (volume `postgres_data`).

Credenciais (defaults do README do Kube News): usuário/banco `kubedevnews`, senha `Pg#123`.
