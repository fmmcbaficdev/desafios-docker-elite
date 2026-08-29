# Desafio 05 — Análise de Logs (Debug do fake-shop)

Stack Docker Compose com um app Flask + PostgreSQL (fake-shop). O `docker-compose.yml` original vinha **quebrado** — o objetivo é **identificar o problema pelos logs** e **corrigir**.

## Missão

- Rodar os serviços do `docker-compose.yml` original
- Listar os logs
- Diagnosticar o problema
- Aplicar a correção

## Entrega

```
05-analise-logs/
├── compose.yaml       Versão CORRIGIDA (bugs resolvidos)
└── .env.example       Template das variáveis
```

## O que estava quebrado

O compose original tinha **3 bugs simultâneos** — o Postgres criava credenciais X, mas o app tentava se conectar com credenciais Y:

| Campo | Postgres cria | App tenta usar | Correto |
|---|---|---|---|
| Usuário | `POSTGRES_USER=ecommerce` | `DB_USER=fakeshop` | ❌ Swap |
| Banco | `POSTGRES_DB=fakeshop` | `DB_NAME=ecommerce` | ❌ Swap |
| Senha | `POSTGRES_PASSWORD=pg1234` | `DB_PASSWORD=Pg1234` | ❌ Case |

**Sintoma clássico**: no `docker compose ps` o container `ecommerce` fica em `Restarting (1)` num loop infinito. Sem olhar os logs, você não sabe o motivo.

## Como diagnosticar (com o compose original quebrado)

```bash
docker compose up -d
docker compose ps                  # ecommerce em "Restarting"
docker compose logs -f ecommerce   # olha os logs pra achar o bug
```

Aparecem mensagens do tipo:

```
psycopg2.OperationalError: FATAL:  password authentication failed for user "fakeshop"
FATAL:  database "ecommerce" does not exist
```

Cada linha aponta um problema:

1. `password authentication failed for user "fakeshop"` → usuário `fakeshop` não existe no Postgres
2. `database "ecommerce" does not exist` → banco `ecommerce` também não existe

Com essas duas mensagens, você casa os nomes com o serviço `postgre` e vê que foi um **swap** entre `DB_USER`/`DB_NAME`.

## Correção aplicada (neste compose.yaml)

```yaml
ecommerce:
  environment:
    DB_HOST: postgre
    DB_USER: ${POSTGRES_USER}       # antes: fakeshop
    DB_PASSWORD: ${POSTGRES_PASSWORD} # antes: Pg1234 (case errado)
    DB_NAME: ${POSTGRES_DB}          # antes: ecommerce
    DB_PORT: "5432"
    FLASK_APP: index.py
```

Bônus: em vez de manter valores literais, referencio as **mesmas variáveis do serviço `postgre`** (`${POSTGRES_USER}`, `${POSTGRES_PASSWORD}`, `${POSTGRES_DB}`) via `.env`. Isso torna **impossível** os dois lados ficarem fora de sincronia no futuro.

## Como executar (versão corrigida)

### 1. Preparar `.env`

```bash
cd desafios-docker-fundamentals/05-analise-logs
cp .env.example .env
```

### 2. Subir

```bash
docker compose up -d
```

### 3. Acompanhar logs em tempo real

```bash
docker compose logs -f
```

Ou por serviço:

```bash
docker compose logs -f ecommerce
docker compose logs -f postgre
```

### 4. Acessar o app

- URL: <http://localhost:5000> (ou a porta em `APP_PORT`)

## Melhorias em relação ao compose original

| Melhoria | Onde | Benefício |
|---|---|---|
| **Variáveis compartilhadas via `.env`** | Ambos os serviços | Impede desalinhamento entre banco e app |
| **`${VAR:-default}`** nas portas | `POSTGRES_PORT`, `APP_PORT` | Fácil trocar porta se houver conflito no host |
| **Healthcheck com `pg_isready`** | `postgre` | Feedback de "banco pronto" |
| **`depends_on: service_healthy`** | `ecommerce` | App só sobe quando banco realmente aceita conexão |
| **Rede dedicada `fakeshop_net`** | Ambos | Isolamento explícito |
| **`container_name`** definidos | Ambos | `docker exec` e `docker logs` ficam previsíveis |
| **`name` do projeto (`fake-shop`)** | Topo do compose | `docker compose ps` mais legível |
| **Volume nomeado `fakeshop_postgre_data`** | Postgres | Não conflita com outros projetos |

## Comandos úteis

```bash
# ── Ciclo de vida ─────────────────────────────────────
docker compose up -d
docker compose down               # mantém volume
docker compose down -v            # ⚠️ apaga volume

# ── Diagnóstico ───────────────────────────────────────
docker compose ps
docker compose logs -f
docker compose logs -f ecommerce
docker compose logs --tail=50 postgre

# Entrar no shell do app pra investigar:
docker compose exec ecommerce sh

# Consultar o banco:
docker compose exec postgre psql -U ecommerce -d fakeshop

# Estatísticas de recursos:
docker stats fakeshop-db fakeshop-app
```

## Troubleshooting

| Sintoma | Onde ver | Causa provável |
|---|---|---|
| `ecommerce` em `Restarting` | `docker compose ps` | Bug de credenciais — ler `docker compose logs ecommerce` |
| `password authentication failed for user "X"` | Logs do `ecommerce` | `DB_USER` != `POSTGRES_USER` |
| `database "X" does not exist` | Logs do `ecommerce` | `DB_NAME` != `POSTGRES_DB` |
| `could not connect to server: Connection refused` | Logs do `ecommerce` | Postgres ainda não subiu (falta `depends_on: service_healthy`) |
| `port is already allocated` no `up` | Saída do `up -d` | Ajustar `POSTGRES_PORT` ou `APP_PORT` no `.env` |

## Lição do desafio

**Logs são a fonte da verdade em containers.** Sem eles, você fica adivinhando. Cheatsheet de investigação:

```
1. docker compose ps                    # quem está de pé, quem não está
2. docker compose logs -f <servico>     # o que ele grita antes de morrer
3. docker compose exec <servico> sh     # entrar e inspecionar env vars
4. docker compose config                # ver como o compose foi renderizado
```

Se os 4 acima não bastarem, o problema geralmente é de rede ou volume — não de env var.
