#!/usr/bin/env bash
# Gera sbom-report.json da imagem endurecida do Kube News (desafio 02).
# Requer: docker login + imagem kube-news:after

set -euo pipefail

OUT="$(cd "$(dirname "$0")" && pwd)/sbom-report.json"
IMAGE="${IMAGE:-kube-news:after}"

docker scout sbom --format json --output "$OUT" "local://${IMAGE}"
echo "SBOM: $OUT"
