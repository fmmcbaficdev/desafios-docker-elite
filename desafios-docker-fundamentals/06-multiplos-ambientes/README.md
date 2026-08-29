# Desafio 06 — Múltiplos ambientes (dev + homologação)

Refatoração do compose do desafio 05 (fake-shop) para suportar **dois ambientes isolados** via arquivos `.env` diferentes, sem alterar o `compose.yaml`.

## Missão

- Alterar o `compose.yaml` para usar variáveis de ambiente em toda config
- Criar dois arquivos:
  - `.dev.env` (desenvolvimento)
  - `.homolog.env` (homologação)
- Cada ambiente sobe **isolado** (containers, volume, rede e banco próprios)

## Entrega

```
06-multiplos-ambientes/
├── compose.yaml       Agnóstico de ambiente (só ${VAR})
├── .dev.env           Configuração do ambiente de desenvolvimento
└── .homolog.env       Configuração do ambiente de homologação
```

> 💡 Os arquivos `.dev.env` e `.homolog.env` **vão para o git** — eles não contêm senhas de produção, apenas configuração por ambiente. Em produção real, o `.env` seria substituído por um cofre (Vault, AWS Secrets Manager, etc.).

## Como executar

### Subir DEV

```bash
cd desafios-docker-fundamentals/06-multiplos-ambientes
docker compose --env-file .dev.env up -d
```

- App: <http://localhost:5000>
- Postgres: `localhost:5435`

### Subir HOMOLOG

```bash
docker compose --env-file .homolog.env up -d
```

- App: <http://localhost:5001>
- Postgres: `localhost:5436`

### Rodar os dois ao mesmo tempo

As portas e o `PROJECT_NAME` são diferentes em cada env — pode subir os dois sem conflito:

```bash
docker compose --env-file .dev.env      up -d
docker compose --env-file .homolog.env  up -d

docker ps --filter "name=fakeshop"
```

Resultado:

```
NAMES                  PORTS                     STATUS
fakeshop-homolog-app   0.0.0.0:5001->5000/tcp    Up
fakeshop-homolog-db    0.0.0.0:5436->5432/tcp    Up (healthy)
fakeshop-dev-app       0.0.0.0:5000->5000/tcp    Up
fakeshop-dev-db        0.0.0.0:5435->5432/tcp    Up (healthy)
```

### Derrubar

```bash
docker compose --env-file .dev.env      down       # mantém volume
docker compose --env-file .homolog.env  down -v    # apaga volume ⚠️
```

## Como funciona o isolamento

O segredo está no **`PROJECT_NAME`** de cada env file — ele prefixa **todos** os recursos criados pelo compose:

| Recurso | Dev | Homolog |
|---|---|---|
| Project | `fakeshop-dev` | `fakeshop-homolog` |
| Container app | `fakeshop-dev-app` | `fakeshop-homolog-app` |
| Container db | `fakeshop-dev-db` | `fakeshop-homolog-db` |
| Rede | `fakeshop-dev_net` | `fakeshop-homolog_net` |
| Volume | `fakeshop-dev_postgre_data` | `fakeshop-homolog_postgre_data` |
| Banco | `fakeshop_dev` | `fakeshop_hml` |
| Porta app | `5000` | `5001` |
| Porta pg | `5435` | `5436` |

**Todos os nomes são diferentes** → zero conflito, zero risco de dados de dev sobrescrevendo homolog.

## Anatomia do `compose.yaml`

```yaml
name: ${PROJECT_NAME}                    # ← project name vem do env

services:
  postgre:
    container_name: ${PROJECT_NAME}-db   # ← prefixo isolando
    environment:
      POSTGRES_USER: ${POSTGRES_USER}    # ← credencial por env
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "${POSTGRES_PORT}:5432"          # ← porta host por env

  ecommerce:
    container_name: ${PROJECT_NAME}-app
    environment:
      DB_HOST: postgre
      DB_USER: ${POSTGRES_USER}          # ← mesma var do banco
      DB_PASSWORD: ${POSTGRES_PASSWORD}
      DB_NAME: ${POSTGRES_DB}
      APP_ENV: ${APP_ENV}                # ← marcador do ambiente
    ports:
      - "${APP_PORT}:5000"

volumes:
  postgre_data:
    name: ${PROJECT_NAME}_postgre_data   # ← volume prefixado

networks:
  fakeshop_net:
    name: ${PROJECT_NAME}_net            # ← rede prefixada
```

**Nenhum valor literal**. Todo o comportamento vem do `--env-file` passado.

## Prova de isolamento

```bash
# Insere um produto SÓ em dev:
docker exec fakeshop-dev-db psql -U ecommerce_dev -d fakeshop_dev \
  -c "INSERT INTO products (name, price, description) VALUES ('Produto DEV', 10.99, 'Existe so em DEV');"

# Insere um produto SÓ em homolog:
docker exec fakeshop-homolog-db psql -U ecommerce_hml -d fakeshop_hml \
  -c "INSERT INTO products (name, price, description) VALUES ('Produto HOMOLOG', 99.99, 'Existe so em HOMOLOG');"

# Confirma que cada um só vê o próprio:
docker exec fakeshop-dev-db     psql -U ecommerce_dev -d fakeshop_dev   -c "SELECT name FROM products WHERE name LIKE 'Produto%';"
docker exec fakeshop-homolog-db psql -U ecommerce_hml -d fakeshop_hml   -c "SELECT name FROM products WHERE name LIKE 'Produto%';"
```

O primeiro retorna só "Produto DEV". O segundo retorna só "Produto HOMOLOG".

## Boas práticas aplicadas

| Prática | Por quê |
|---|---|
| **`--env-file`** em vez de `.env` default | Escolha explícita do ambiente — impossível "esquecer" que subiu com dev |
| **`PROJECT_NAME` em `name:` do compose** | Isola todos os recursos automaticamente |
| **Variáveis compartilhadas entre serviços** | Impede desalinhamento (bug do desafio 05) |
| **Portas configuráveis** | Envs coexistem no mesmo host |
| **Healthcheck + `depends_on: service_healthy`** | App só sobe quando o banco está pronto |
| **`APP_ENV` como marcador** | Log/métrica sabe de qual ambiente vem |
| **Senhas sem `@`, `:` ou `/`** | Evita quebrar URIs do tipo `postgresql://user:pass@host:port/db` |

## ⚠️ Armadilha resolvida — caracteres especiais em senhas

Se a senha do Postgres contiver `@`, `:` ou `/`, e a app construir uma URI de conexão do tipo:

```
postgresql://ecommerce_hml:Homolog@Pg1234@postgre:5432/fakeshop_hml
                          ↑ user     ↑ isso vira o host??
```

O parser trata o **primeiro `@`** como separador user/host. Resultado: erro cripático **`Name or service not known`** no DNS lookup — mesmo com o hostname correto no `DB_HOST`.

**Solução**: evite esses 3 caracteres em senhas, ou URL-encode (`@` → `%40`).

Por isso a senha do `.homolog.env` foi trocada de `Homolog@Pg1234` para `HomologPg1234!`.

## Cheat sheet

```bash
# Ver o que o compose vai renderizar com um env file (sem subir):
docker compose --env-file .dev.env config

# Subir só a versão dev:
docker compose --env-file .dev.env up -d

# Ver status por ambiente:
docker compose --env-file .dev.env ps

# Logs por ambiente:
docker compose --env-file .dev.env logs -f
docker compose --env-file .homolog.env logs -f ecommerce

# Executar comando em um container específico:
docker compose --env-file .dev.env exec postgre psql -U ecommerce_dev -d fakeshop_dev

# Derrubar tudo de um ambiente:
docker compose --env-file .dev.env down          # preserva volume
docker compose --env-file .dev.env down -v       # apaga volume ⚠️

# Derrubar OS DOIS ambientes:
docker compose --env-file .dev.env      down
docker compose --env-file .homolog.env  down
```

## Extensão sugerida

Para acrescentar um ambiente novo (ex.: `staging`, `prod-preview`):

1. Copia `.homolog.env` → `.staging.env`
2. Ajusta `PROJECT_NAME`, portas e credenciais
3. `docker compose --env-file .staging.env up -d`

O `compose.yaml` **não precisa ser alterado**.
