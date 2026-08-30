#!/usr/bin/env bash
# Gera vulnerabilities-report.sarif a partir das deps pip do fake-shop.
# Requer: Docker (imagem aquasec/trivy) e requirements.txt em fake-shop/src.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$ROOT/fake-shop/src"
OUT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$OUT_DIR/vulnerabilities-report.sarif"

if [[ ! -f "$SRC/requirements.txt" ]]; then
  echo "fake-shop/src/requirements.txt nao encontrado. Clone o repo na raiz:"
  echo "  git clone https://github.com/KubeDev/fake-shop.git"
  exit 1
fi

if [[ ! -d "$SRC/.venv" ]]; then
  echo "Instalando dependencias em fake-shop/src..."
  python -m venv "$SRC/.venv"
  if [[ -x "$SRC/.venv/bin/pip" ]]; then
    "$SRC/.venv/bin/pip" install -r "$SRC/requirements.txt"
  else
    "$SRC/.venv/Scripts/pip.exe" install -r "$SRC/requirements.txt"
  fi
fi

echo "Escaneando filesystem (pip) com Trivy — nao e scan de imagem..."
# MSYS_NO_PATHCONV: no Git Bash, /src e /out virariam caminhos do Windows.
MSYS_NO_PATHCONV=1 docker run --rm \
  -v "${SRC}:/work:ro" \
  -v "${OUT_DIR}:/out" \
  -v trivy-cache:/root/.cache/trivy \
  aquasec/trivy:latest fs \
  --scanners vuln \
  --pkg-types library \
  --skip-dirs .venv \
  --format sarif \
  --output /out/vulnerabilities-report.sarif \
  /work

echo "Relatorio: $OUT"
