# Desafios Docker — Segurança

Terceira trilha da coletânea. Foco em **segurança da cadeia de suprimentos de imagens Docker**: scan de vulnerabilidades, hardening de Dockerfile, SBOM, imagens distroless e assinatura (Cosign).

## Introdução

A equipe de engenharia da Rota42 identificou vulnerabilidades e práticas inseguras na forma como as imagens Docker estão sendo construídas e gerenciadas.

Os times de desenvolvimento e DevOps utilizam diferentes aplicações, incluindo:

- **Kube News** — portal de notícias baseado em Kubernetes
- **Fake Shop** — loja virtual fake para demonstração de práticas DevOps

Com a crescente preocupação com segurança na cadeia de suprimentos de software, a Rota42 iniciou uma revisão completa dos processos de construção e gerenciamento de imagens Docker. O objetivo é identificar falhas, propor soluções e automatizar verificações de segurança para tornar o ambiente mais confiável e resistente a ataques.

Esta trilha aplica o mesmo ciclo em **duas aplicações**:

| Ciclo | Kube News (Node.js) | Fake Shop (Python) |
|---|---|---|
| Identificar vulnerabilidades | `01-identificando-vulnerabilidades` | `05-identificando-vulnerabilidades-fake-shop` |
| Hardening da imagem | `02-imagem-docker-segura` | `06-imagem-docker-segura-fake-shop` |
| SBOM | `03-sbom-docker-scout` | `07-sbom-trivy-fake-shop` |
| Distroless + Cosign | `04-distroless-e-cosign` | `08-distroless-e-cosign-fake-shop` |

## Índice de desafios

| # | Desafio | App | Entrega esperada |
|---|---|---|---|
| 01 | [Identificando vulnerabilidades](01-identificando-vulnerabilidades/) | Kube News | `vulnerabilities-report.sarif` |
| 02 | [Imagem Docker segura](02-imagem-docker-segura/) | Kube News | `Dockerfile`, relatórios before/after + Hadolint |
| 03 | [SBOM com Docker Scout](03-sbom-docker-scout/) | Kube News | `sbom-report.json` |
| 04 | [Distroless e Cosign](04-distroless-e-cosign/) | Kube News | `Dockerfile`, `cosign-signature.txt` |
| 05 | [Identificando vulnerabilidades](05-identificando-vulnerabilidades-fake-shop/) | Fake Shop | `vulnerabilities-report.sarif` |
| 06 | [Imagem Docker segura](06-imagem-docker-segura-fake-shop/) | Fake Shop | `Dockerfile`, relatórios before/after + Hadolint |
| 07 | [SBOM com Trivy](07-sbom-trivy-fake-shop/) | Fake Shop | `sbom-report.json` |
| 08 | [Distroless e Cosign](08-distroless-e-cosign-fake-shop/) | Fake Shop | `Dockerfile`, `cosign-signature.txt` |

_Desafios 01–05 concluídos (Kube News 01–04; Fake Shop 05). Os demais aguardam o enunciado._

## Convenções da trilha

- Cada desafio vive em uma pasta numerada (`01-` … `08-`) com o nome oficial do curso
- Relatórios de scan (SARIF, SBOM, Hadolint, Cosign) são **artefatos gerados**, não inventados à mão
- Cada pasta traz um `README.md` público quando o desafio for implementado
- `DESAFIO.md` (local, não versionado) guarda o roteiro de scan e o racional das correções
- Line endings **LF** forçados via `.gitattributes` da raiz do repo
