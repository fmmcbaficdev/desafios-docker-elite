# Desafio 03 (trilha 2) — ENTRYPOINT vs CMD

Containerizar o pipeline de conversão de vídeos da Rota42 (FFmpeg + `convert.sh`) usando **ENTRYPOINT + CMD corretamente**, de forma que:

- Sem argumentos, o container tenha um comportamento padrão sensato
- Com argumentos, o usuário passe parâmetros dinâmicos que são repassados ao script

## Missão

Criar um `Dockerfile` que:
- Instale as dependências (`ffmpeg`)
- Copie o `convert.sh` para dentro da imagem
- Configure **ENTRYPOINT** (comando fixo) e **CMD** (args default) de forma a permitir:
  - Comportamento padrão sem argumentos
  - Passagem de argumentos dinâmicos

Criar um `compose.yaml` que:
- Construa a imagem
- Facilite rodar com diferentes parâmetros para testar ENTRYPOINT e CMD

## Entrega

```
03-entrypoint-vs-cmd/
├── Dockerfile           ← ENTRYPOINT + CMD estruturados
├── compose.yaml         ← service base + exemplos via profiles
├── convert.sh           ← script da equipe (não modificado)
├── .dockerignore        ← whitelist (não envia videos/ para o daemon)
└── videos/              ← bind mount alvo (/work no container)
```

## ENTRYPOINT vs CMD — a regra de ouro

| | ENTRYPOINT | CMD |
|---|---|---|
| **O que define?** | O que o container executa (comando **fixo**) | Argumentos **default** que podem ser sobrescritos |
| **Sobrescrito em `docker run`?** | Só com `--entrypoint` (raro) | Automaticamente com qualquer args após a imagem |
| **Uso típico** | O binário/script que dá "personalidade" à imagem | Argumentos default do binário |

**Combinação usada neste desafio**:

```dockerfile
ENTRYPOINT ["/usr/local/bin/convert.sh"]
CMD ["--help"]
```

Resultado prático:

| Comando | Executa | Resultado |
|---|---|---|
| `docker run img` | `convert.sh --help` | Mostra usage (CMD default) |
| `docker run img video.mp4 avi` | `convert.sh video.mp4 avi` | Converte |
| `docker run --entrypoint sh img -c 'ffmpeg -version'` | `sh -c ffmpeg -version` | Sobrescreve ENTRYPOINT |

## Como testar

Pré-requisito: colocar um vídeo em `./videos/` (ou gerar um — ver seção abaixo).

### 1. Buildar

```bash
cd desafios-docker-images/03-entrypoint-vs-cmd
docker compose build
```

### 2. Sem argumentos (CMD default = `--help`)

```bash
docker compose run --rm converter
```

Saída esperada:

```
Uso: convert.sh <arquivo de entrada> <formato de saída>
Exemplo: convert.sh video.mp4 avi
```

O `convert.sh` recebe `--help` (1 arg), não reconhece como 2 args, cai no branch de usage e sai com código 1. **É o comportamento padrão desejado**: sem instruções, o container ensina como usar.

### 3. Com argumentos dinâmicos

```bash
# Coloque um video.mp4 em ./videos/ antes:
docker compose run --rm converter video.mp4 avi
docker compose run --rm converter video.mp4 mov
docker compose run --rm converter musica.wav mp3
```

Os args após `converter` sobrescrevem o CMD do Dockerfile e são passados como `$1` (arquivo de entrada) e `$2` (formato de saída) para o script. O ENTRYPOINT (`convert.sh`) **permanece** — o que muda são os argumentos.

Os arquivos convertidos aparecem em `./videos/output.<formato>` (bind mount de `/work`).

### 4. Cenários pré-configurados via profile `examples`

```bash
docker compose --profile examples run --rm mp4-para-avi
docker compose --profile examples run --rm mp4-para-mov
docker compose --profile examples run --rm mp4-para-mkv
```

Cada service tem `command: [...]` fixo, demonstrando que `command:` do compose sobrescreve o CMD do Dockerfile. Útil como atalho para conversões recorrentes.

### 5. Sobrescrever ENTRYPOINT (raro, mas possível)

```bash
docker compose run --rm --entrypoint ffmpeg converter -version
docker compose run --rm --entrypoint sh converter -c "ls -la /work"
```

O `--entrypoint` reescreve o ENTRYPOINT do Dockerfile. Útil para debug ou tarefas ad-hoc que não são a "personalidade" da imagem.

## Não tem um vídeo para testar?

Gere um dentro do próprio container (2 segundos, 30 KB, com áudio):

```bash
docker compose run --rm --entrypoint ffmpeg converter \
  -f lavfi -i "testsrc=duration=2:size=320x240:rate=15" \
  -f lavfi -i "sine=frequency=440:duration=2" \
  -c:v libx264 -c:a aac -shortest -y video.mp4
```

Depois:

```bash
docker compose run --rm converter video.mp4 avi
# ls videos/output.avi
```

## Anatomia do Dockerfile — as decisões

### Base `alpine:3.20`

- Alpine ~5 MB. `ffmpeg` do apk é ~180 MB (traz libx264, libx265, libvpx, aac, opus). Total: **~189 MB**.
- Alpine já tem `/bin/sh` (`ash`). O `convert.sh` começa com `#!/bin/sh` — não precisa instalar bash.

### `apk add --no-cache ffmpeg`

- `--no-cache` evita deixar o índice do apk na imagem.
- Uma única linha instala tudo (codecs vêm junto).

### Non-root user

```dockerfile
RUN addgroup -S -g 1000 converter && \
    adduser  -S -u 1000 -G converter converter
USER converter
```

Conversão de vídeo não precisa de privilégios. Reduz superfície de ataque caso algum arquivo de entrada malicioso explore o ffmpeg.

### `COPY --chmod=755`

```dockerfile
COPY --chmod=755 --chown=converter:converter convert.sh /usr/local/bin/convert.sh
```

O flag `--chmod` (BuildKit) evita um `RUN chmod +x` extra e a camada correspondente. Uma linha faz tudo: copia, define permissão e ownership.

### `WORKDIR /work`

O script escreve `output.$FORMATO` **relativo ao WORKDIR**. Bind mount de `./videos:/work` no compose expõe o resultado no host.

## Anatomia do compose.yaml

Uso de âncora YAML para não repetir a configuração de volume:

```yaml
x-converter-base: &converter-base
  image: rota42/video-converter:1.0
  volumes:
    - ./videos:/work

services:
  converter:
    <<: *converter-base
    build:
      context: .
      dockerfile: Dockerfile

  mp4-para-avi:
    <<: *converter-base
    profiles: ["examples"]
    command: ["video.mp4", "avi"]
```

- `converter` — service principal, buildável, alvo do `docker compose run --rm converter ARGS`
- Services em `profiles: ["examples"]` — só sobem com `docker compose --profile examples`, evitam poluir o `docker compose ps` no dia a dia

## Cheat sheet

```bash
# Build
docker compose build

# Executar (sem args = ver usage / com args = converte):
docker compose run --rm converter                     # help
docker compose run --rm converter video.mp4 avi       # converte

# Exemplos pré-configurados:
docker compose --profile examples run --rm mp4-para-avi
docker compose --profile examples run --rm mp4-para-mov
docker compose --profile examples run --rm mp4-para-mkv

# Sobrescrever ENTRYPOINT:
docker compose run --rm --entrypoint ffmpeg converter -version
docker compose run --rm --entrypoint sh converter -c "ls -la /work"

# Ver a imagem:
docker images rota42/video-converter:1.0
```

## Resultados validados

- **Tamanho da imagem**: 189 MB (Alpine + ffmpeg completo)
- **Usuário**: `uid=1000(converter)` — non-root ✅
- **Conversões testadas**: MP4 → AVI (42 KB), MOV (32 KB), MKV (31 KB) — todas com sucesso
- **CMD default**: exibe usage quando sem args ✅
- **CMD sobrescrito**: aceita args após o nome do service (`converter arg1 arg2`) ✅
- **ENTRYPOINT sobrescrito**: `--entrypoint ffmpeg` funcionou para gerar o vídeo de teste ✅
