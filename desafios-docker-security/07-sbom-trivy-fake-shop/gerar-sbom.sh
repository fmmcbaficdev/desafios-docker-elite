#!/usr/bin/env bash
# Gera sbom-report.json (CycloneDX) da imagem endurecida do Fake Shop (desafio 06).
# Requer: Docker (aquasec/trivy) e imagem fake-shop:after

set -euo pipefail

OUT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$OUT_DIR/sbom-report.json"
IMAGE="${IMAGE:-fake-shop:after}"

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "Imagem $IMAGE nao encontrada. Construa a imagem do desafio 06 (fake-shop:after)."
  exit 1
fi

echo "Gerando SBOM CycloneDX de $IMAGE..."
# MSYS_NO_PATHCONV: no Git Bash, /out viraria caminho do Windows.
MSYS_NO_PATHCONV=1 docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "${OUT_DIR}:/out" \
  -v trivy-cache:/root/.cache/trivy \
  aquasec/trivy:latest image \
  --format cyclonedx \
  --pkg-types os,library \
  --output /out/sbom-report.json \
  "$IMAGE"

echo "SBOM: $OUT"
