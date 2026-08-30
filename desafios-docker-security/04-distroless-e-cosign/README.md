# Desafio 04 (trilha 3) — Distroless Chainguard e Cosign (Kube News)

A imagem Alpine do desafio 02 ainda carrega um sistema de pacotes. Este desafio reduz a superfície de ataque com **Distroless Chainguard** e assina o artefato com **Cosign** antes da publicação.

## Entrega

```
04-distroless-e-cosign/
├── Dockerfile              ← multi-stage Chainguard Distroless
├── cosign.pub              ← chave pública (verificação)
├── cosign-signature.txt    ← bundle Sigstore da assinatura
└── README.md
```

`cosign.key` (chave privada) **não** entra no repositório.

## Imagem no Docker Hub

| | |
|---|---|
| Nome | `francisbene/kube-news-distroless` |
| Tags | `1.0`, `latest` |
| Digest | `sha256:bb9c375f01a24f704867849de03020a84328c97f0d2deaebf46da16a0a0d7f9d` |
| URL | https://hub.docker.com/r/francisbene/kube-news-distroless |

```
docker pull francisbene/kube-news-distroless:1.0
```

Tamanho local (`docker images`): **306 MB** (Alpine do desafio 02: 325 MB). Runtime Distroless: sem shell, sem gerenciador de pacotes, `USER 65532`.

## Dockerfile

| Stage | Base | Função |
|---|---|---|
| `builder` | `cgr.dev/chainguard/node:latest-dev` | `npm ci --omit=dev` (tem npm/shell) |
| runtime | `cgr.dev/chainguard/node:latest` | Distroless: só Node + app |

A base Chainguard já define `ENTRYPOINT ["/usr/bin/node"]`, então o `CMD` é só `["server.js"]`.

## Como verificar a assinatura

Requisito: [Cosign](https://docs.sigstore.dev/cosign/system_config/installation/) v2+.

A verificação usa a **chave pública** (`cosign.pub`) e o **digest** (não só a tag — a tag pode ser movida).

```bash
# a partir desta pasta (cosign.pub no cwd)
cosign verify --key cosign.pub \
  francisbene/kube-news-distroless@sha256:bb9c375f01a24f704867849de03020a84328c97f0d2deaebf46da16a0a0d7f9d
```

Saída esperada: `The signatures were verified against the specified public key` e um JSON com `docker-manifest-digest` igual ao digest acima.

O arquivo `cosign-signature.txt` é o bundle obtido com:

```bash
cosign download signature \
  francisbene/kube-news-distroless@sha256:bb9c375f01a24f704867849de03020a84328c97f0d2deaebf46da16a0a0d7f9d
```

A assinatura também está no registry (referrer OCI). Quem puxa a imagem do Hub pode verificar sem esse arquivo, desde que tenha `cosign.pub`.

## Como reproduzir

Contexto de build: `kube-news/src` (mesmo `package.json` endurecido do desafio 02).

```bash
# 1. Build
docker build -f Dockerfile -t kube-news-distroless:latest ../../kube-news/src
# (neste repo o clone fica na raiz: kube-news/src)

# 2. Publicar
docker tag kube-news-distroless:latest francisbene/kube-news-distroless:1.0
docker push francisbene/kube-news-distroless:1.0

# 3. Assinar pelo digest (nunca só pela tag)
DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' francisbene/kube-news-distroless:1.0)
cosign sign --key cosign.key -y "$DIGEST"
```
