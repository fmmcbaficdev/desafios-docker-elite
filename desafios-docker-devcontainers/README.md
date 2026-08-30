# Desafios Docker — DevContainers

Quarta trilha da coletânea. Foco em **ambiente de desenvolvimento reproduzível** com DevContainers no VS Code: a mesma stack sobe em qualquer máquina, sem instalação manual de runtime, dependências ou banco.

## Introdução

A Rota42 está expandindo suas operações e investindo em boas práticas de desenvolvimento e infraestrutura para tornar seus times mais produtivos e garantir a qualidade dos seus produtos. Um dos principais desafios enfrentados pela equipe de engenharia é a configuração inconsistente do ambiente de desenvolvimento.

Atualmente, cada desenvolvedor precisa configurar manualmente o ambiente local, instalando dependências, ajustando variáveis de ambiente e garantindo compatibilidade entre diferentes sistemas operacionais. Isso causa erros imprevisíveis, desperdício de tempo e dificuldades na colaboração entre os times.

Diante desse cenário, a equipe decidiu containerizar completamente o ambiente de desenvolvimento utilizando DevContainers no VS Code, garantindo que todos os desenvolvedores possam iniciar um ambiente pronto para codificação sem configurações manuais.

Para testar essa abordagem, os projetos **Kube News** e **Fake Shop** foram escolhidos como pilotos.

## Estrutura esperada

Cada piloto separa **produção** (raiz do projeto) de **desenvolvimento** (`.devcontainer/`).

```
desafios-docker-devcontainers/
├── kube-news/
│   ├── .devcontainer/
│   │   ├── devcontainer.json              # Extensões e ambiente
│   │   ├── Dockerfile.dev                 # Imagem de desenvolvimento
│   │   └── docker-compose.override.yml    # Ajustes do DevContainer
│   ├── compose.yml                        # Compose de produção
│   ├── Dockerfile                         # Imagem de produção
│   └── README.md                          # Como subir cada ambiente
└── fake-shop/
    ├── .devcontainer/
    │   ├── devcontainer.json
    │   ├── Dockerfile.dev
    │   └── docker-compose.override.yml
    ├── compose.yml
    ├── Dockerfile
    └── README.md
```

O primeiro recorte do Kube News usa só `.devcontainer/` (`devcontainer.json`, `Dockerfile`, `docker-compose.yml` com volumes persistentes). A árvore acima é o recorte final, com produção e DevContainer lado a lado.

O código-fonte das apps continua nos clones da raiz (`/kube-news`, `/fake-shop`, gitignored). As pastas desta trilha guardam uma cópia da entrega; o desafio 01 também está no fork https://github.com/fmmcbaficdev/kube-news.

## Índice

| # | Desafio | App | Entrega |
|---|---|---|---|
| 01 | [DevContainer Kube News](kube-news/) | Kube News | `.devcontainer/` no [fork](https://github.com/fmmcbaficdev/kube-news) |
| 02 | [Extensões e volumes](kube-news/) | Kube News | extensões VS Code, volume Postgres, `npm install` automático |
| 03 | [Prod vs Dev](kube-news/) | Kube News | `Dockerfile` + `compose.yml` + `Dockerfile.dev` + override |
| 04 | [DevContainer Fake Shop](fake-shop/) | Fake Shop | mesmo recorte prod/dev no [fork](https://github.com/fmmcbaficdev/fake-shop) |

_Desafios 01–04 implementados (Kube News e Fake Shop)._

## Convenções da trilha

- Produção fica na raiz do piloto (`Dockerfile` + `compose.yml`)
- DevContainer fica em `.devcontainer/` (`Dockerfile.dev` + `docker-compose.override.yml`)
- `DESAFIO.md` (local, não versionado) guarda o roteiro técnico
- Line endings **LF** via `.gitattributes` da raiz
