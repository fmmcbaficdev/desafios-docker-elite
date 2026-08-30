# Desafio 08 (trilha 3) — Distroless Chainguard e Cosign (Fake Shop)

A imagem Alpine do desafio 06 ainda carrega um sistema de pacotes. Este desafio reduz a superfície de ataque com **Distroless Chainguard** e assina o artefato com **Cosign** antes da publicação.

## Entrega

```
08-distroless-e-cosign-fake-shop/
├── Dockerfile              ← multi-stage Chainguard Distroless
├── cosign.pub              ← chave pública (verificação)
├── cosign-signature.txt    ← bundle Sigstore da assinatura
└── README.md
```

`cosign.key` (chave privada) **não** entra no repositório.

## Imagem no Docker Hub

| | |
|---|---|
| Nome | `francisbene/fake-shop-distroless` |
| Tags | `1.0`, `latest` |
| Digest | `sha256:b0b59cce97c305832522532b50b45c39ac0414c68234a37cbc1c6eca55d20e60` |
| URL | https://hub.docker.com/r/francisbene/fake-shop-distroless |

```
docker pull francisbene/fake-shop-distroless:1.0
```

Tamanho local (`docker images`): **201 MB** (Alpine do desafio 06: 187 MB). Runtime Distroless: sem shell, sem gerenciador de pacotes, `USER 65532`.

O catálogo público Chainguard só oferece `python:latest` (hoje **Python 3.14**). O `requirements.txt` do enunciado (3.11) exige um ajuste no **builder**: `greenlet>=3.2`, `psycopg[binary]>=3.2.10` e `SQLAlchemy>=2.0.40` — senão o pip/SQLAlchemy quebram no 3.14. A app continua a mesma.

## Dockerfile

| Stage | Base | Função |
|---|---|---|
| `builder` | `cgr.dev/chainguard/python:latest-dev` | venv + pip (tem shell) |
| runtime | `cgr.dev/chainguard/python:latest` | Distroless: só Python + app |

`ENTRYPOINT` da base (`/usr/bin/python`) é sobrescrito por `/app/venv/bin/python` para o gunicorn do venv.

## Como verificar a assinatura

Requisito: [Cosign](https://docs.sigstore.dev/cosign/system_config/installation/) v2+.

A verificação usa a **chave pública** (`cosign.pub`) e o **digest** (não só a tag).

```bash
cosign verify --key cosign.pub \
  francisbene/fake-shop-distroless@sha256:b0b59cce97c305832522532b50b45c39ac0414c68234a37cbc1c6eca55d20e60
```

Saída esperada: `The signatures were verified against the specified public key`.

O arquivo `cosign-signature.txt` é o bundle de:

```bash
cosign download signature \
  francisbene/fake-shop-distroless@sha256:b0b59cce97c305832522532b50b45c39ac0414c68234a37cbc1c6eca55d20e60
```

## Como reproduzir

Contexto: `fake-shop/src` (requirements do desafio 06).

```bash
docker build -f Dockerfile -t fake-shop-distroless:latest ../../fake-shop/src

docker tag fake-shop-distroless:latest francisbene/fake-shop-distroless:1.0
docker push francisbene/fake-shop-distroless:1.0

DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' francisbene/fake-shop-distroless:1.0)
cosign sign --key cosign.key -y "$DIGEST"
```
