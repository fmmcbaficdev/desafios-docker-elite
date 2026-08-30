# Desafio 03 (trilha 3) — SBOM com Docker Scout (Kube News)

Com a imagem endurecida no desafio 02, a Rota42 precisa de um **SBOM** (Software Bill of Materials): inventário de pacotes OS e bibliotecas da aplicação para rastrear CVEs futuras.

## Entrega

```
03-sbom-docker-scout/
├── sbom-report.json    ← SBOM Scout (JSON)
├── gerar-sbom.sh
└── README.md
```

## Resultado

Imagem: `kube-news:after` (`sha256:aecbc6f2c772…`)

| Tipo | Pacotes |
|---|---:|
| npm | 319 |
| apk (Alpine) | 22 |
| github | 1 |
| **Total** | **342** |

Arquivo: `sbom-report.json` (~409 KB). Formato nativo do Docker Scout (`--format json`).

## Como reproduzir

```bash
# Imagem do desafio 02 precisa existir localmente
docker scout sbom --format json --output sbom-report.json local://kube-news:after
```

Ou: `./gerar-sbom.sh`

`local://` evita lookup no registry. `--format json` é o default do Scout e atende o enunciado (integração com ferramentas de análise).

Outros formatos disponíveis (`spdx`, `cyclonedx`) servem a outras ferramentas; a entrega pede JSON.
