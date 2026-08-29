# Desafio 01 (trilha 3) — Identificando vulnerabilidades (Kube News)

Primeiro passo da auditoria de segurança da Rota42: analisar **somente as dependências npm** do Kube News e gerar um relatório **SARIF** para CI/CD. A imagem Docker **não** entra neste scan.

## Missão

- Clonar o Kube News e instalar as dependências
- Escanear as deps com **Docker Scout** (`fs://`, não `image://`)
- Gerar `vulnerabilities-report.sarif`

## Entrega

```
01-identificando-vulnerabilidades/
├── vulnerabilities-report.sarif   ← relatório Scout (npm)
├── gerar-relatorio.sh             ← reproduz o scan
└── README.md
```

## Como gerar o relatório

Pré-requisito: **login no Docker Hub** (`docker login` ou Sign in no Docker Desktop). O Scout recusa scan sem autenticação.

```bash
# 1. App na raiz do repo (ja ignorada no git)
git clone https://github.com/KubeDev/kube-news.git

# 2. Instalar deps
cd kube-news/src
npm install

# 3. Scan do filesystem (somente npm)
cd ../../desafios-docker-security/01-identificando-vulnerabilidades
docker scout cves \
  --format sarif \
  --only-package-type npm \
  --output vulnerabilities-report.sarif \
  fs://../../kube-news/src
```

Ou: `./gerar-relatorio.sh`

## Por que `fs://` e não a imagem

| Prefixo | O que analisa |
|---|---|
| `image://` (default) | Camadas da imagem (OS + app) |
| **`fs://`** | Diretório local: `package.json` / lock / `node_modules` |

`--only-package-type npm` impede misturar CVE de Alpine/Debian se o Scout achar outro ecosystem.

## Como ler o SARIF

O arquivo é JSON. Ferramentas que importam SARIF: GitHub Code Scanning, VS Code (SARIF Viewer), Azure DevOps.

## Resultado do scan (Docker Scout 1.18.3)

- Artefato: `fs://kube-news/src` — **117 pacotes npm** indexados
- **18 pacotes vulneráveis**, **35 CVEs** (43 findings no SARIF, alguns CVEs em mais de um package)
- Arquivo: `vulnerabilities-report.sarif` (SARIF 2.1.0, ~244 KB)

| Severidade | CVEs |
|---|---:|
| CRITICAL | 4 |
| HIGH | 14 |
| MEDIUM | 10 |
| LOW | 7 |

Exemplos: `express@4.18.1` (CVE-2024-43796, XSS em `redirect`), `cookie@0.5.0` (CVE-2024-47764), `brace-expansion` (CVE-2025-5889). O desafio 02 trata de atualizar o que for possível e endurecer a imagem.

O próximo desafio (02) endurece a imagem e atualiza o que for possível.
