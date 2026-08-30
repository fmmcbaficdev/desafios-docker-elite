# Imagem oficial de Dev Container com Node.js LTS, git e usuário `vscode`.
FROM mcr.microsoft.com/devcontainers/javascript-node:22

# Cliente do Postgres para inspecionar o banco a partir do container da app.
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspaces/kube-news
