#!/usr/bin/env bash
# Gera vulnerabilities-report.sarif a partir das deps npm do kube-news.
# Requer: docker login (Docker Scout) e node_modules em kube-news/src.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$ROOT/kube-news/src"
OUT="$(cd "$(dirname "$0")" && pwd)/vulnerabilities-report.sarif"

if [[ ! -f "$SRC/package.json" ]]; then
  echo "kube-news/src/package.json nao encontrado. Clone o repo na raiz:"
  echo "  git clone https://github.com/KubeDev/kube-news.git"
  exit 1
fi

if [[ ! -d "$SRC/node_modules" ]]; then
  echo "Instalando dependencias em kube-news/src..."
  (cd "$SRC" && npm install)
fi

echo "Escaneando filesystem (npm) com Docker Scout — nao e scan de imagem..."
docker scout cves \
  --format sarif \
  --only-package-type npm \
  --output "$OUT" \
  "fs://${SRC}"

echo "Relatorio: $OUT"
