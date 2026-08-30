# Desafio 05 (trilha 3) — Identificando vulnerabilidades (Fake Shop)

Mesmo ciclo do desafio 01, agora no **Fake Shop** (Flask). Analisar **somente as dependências Python** e gerar um relatório **SARIF**. A imagem Docker **não** entra neste scan.

## Missão

- Clonar o Fake Shop e instalar as dependências
- Escanear as deps com **Trivy** (`fs`, não `image`)
- Gerar `vulnerabilities-report.sarif`

## Entrega

```
05-identificando-vulnerabilidades-fake-shop/
├── vulnerabilities-report.sarif   ← relatório Trivy (pip)
├── gerar-relatorio.sh             ← reproduz o scan
└── README.md
```

## Como gerar o relatório

Pré-requisito: **Docker Desktop** (a entrega usa a imagem `aquasec/trivy`).

```bash
# 1. App na raiz do repo (ja ignorada no git)
git clone https://github.com/KubeDev/fake-shop.git

# 2. Instalar deps
cd fake-shop/src
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt

# 3. Scan do filesystem (somente bibliotecas da app — pip)
cd ../../desafios-docker-security/05-identificando-vulnerabilidades-fake-shop
MSYS_NO_PATHCONV=1 docker run --rm \
  -v "$PWD/../../fake-shop/src:/work:ro" \
  -v "$PWD:/out" \
  aquasec/trivy:latest fs \
  --scanners vuln \
  --pkg-types library \
  --skip-dirs .venv \
  --format sarif \
  --output /out/vulnerabilities-report.sarif \
  /work
```

Ou: `./gerar-relatorio.sh`

## Por que `fs` e não `image`

| Comando | O que analisa |
|---|---|
| `trivy image` | Camadas da imagem (OS + app) |
| **`trivy fs`** | Diretório local: `requirements.txt` / lock / site-packages |

`--pkg-types library` limita o scan a pacotes de linguagem (pip). `--scanners vuln` não inclui misconfig de Dockerfile nem secrets.

## Como ler o SARIF

O arquivo é JSON. Ferramentas que importam SARIF: GitHub Code Scanning, VS Code (SARIF Viewer), Azure DevOps.

## Resultado do scan (Trivy 0.74.0)

- Artefato: `fake-shop/src/requirements.txt` — **pip**
- **41 vulnerabilidades** (SARIF 2.1.0, ~407 KB)

| Severidade | Findings |
|---|---:|
| CRITICAL | 2 |
| HIGH | 24 |
| MEDIUM | 14 |
| LOW | 1 |

| Pacote | Versão pinada | Findings |
|---|---|---:|
| GitPython | 3.1.0 | 26 (incl. 2 CRITICAL: CVE-2022-24439 RCE, CVE-2023-40267) |
| Werkzeug | 3.0.4 | 5 |
| Jinja2 | 3.1.2 | 5 |
| Mako | 1.3.5 | 2 |
| gunicorn | 21.0.0 | 2 (HTTP request smuggling) |
| Flask | 3.0.0 | 1 |

O desafio 06 trata de atualizar o que for possível e endurecer a imagem.
