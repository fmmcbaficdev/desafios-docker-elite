# Desafio 07 (trilha 3) — SBOM com Trivy (Fake Shop)

Com a imagem endurecida no desafio 06, a Rota42 precisa de um **SBOM** (Software Bill of Materials): inventário de pacotes OS e bibliotecas da aplicação para rastrear CVEs futuras.

## Entrega

```
07-sbom-trivy-fake-shop/
├── sbom-report.json    ← SBOM Trivy (CycloneDX JSON)
├── gerar-sbom.sh
└── README.md
```

## Resultado

Imagem: `fake-shop:after` (`sha256:e6419aa3ce9b…`) — a imagem **corrigida** do desafio 06.

| Tipo | Componentes |
|---|---:|
| pypi (Python) | 81 |
| apk (Alpine) | 39 |
| OS (Alpine 3.24.1) | 1 |
| **Total** | **121** |

Arquivo: `sbom-report.json` (~148 KB). Formato **CycloneDX 1.7** (`bomFormat: CycloneDX`) — JSON padrão de SBOM, compatível com ferramentas de auditoria.

`--format cyclonedx` no Trivy **não** é scan de CVE: só inventário. Vulnerabilidades ficaram nos SARIF do desafio 06.

## Como reproduzir

```bash
# Imagem do desafio 06 precisa existir localmente
MSYS_NO_PATHCONV=1 docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD:/out" \
  aquasec/trivy:latest image \
  --format cyclonedx \
  --pkg-types os,library \
  --output /out/sbom-report.json \
  fake-shop:after
```

Ou: `./gerar-sbom.sh`

`--pkg-types os,library` inclui Alpine **e** pip. Outros formatos Trivy (`spdx-json`, `json` nativo) também são JSON; CycloneDX é o SBOM que o Trivy documenta para cadeia de suprimentos.
