# Desafio 04 — Ambiente kube-news (PostgreSQL + pgAdmin)

Stack Docker Compose que padroniza o ambiente de desenvolvimento do microsserviço [kube-news](https://github.com/KubeDev/kube-news), fornecendo **PostgreSQL** persistente e uma **ferramenta web de administração** (pgAdmin) — sem que os devs precisem instalar nada localmente.

## Missão

- Serviço `db` (PostgreSQL)
- Serviço `db_explorer` (pgAdmin)
- Persistência em ambos os serviços via volumes
- Porta do banco exposta ao **host** para que a app NodeJS rodando fora do Docker consiga conectar

## Entrega

```
04-ambiente/
├── compose.yaml       Orquestração
└── .env.example       Template das variáveis de ambiente
```

## Como executar

### 1. Configurar variáveis

```bash
cd desafios-docker-fundamentals/04-ambiente
cp .env.example .env
# opcional: ajuste as portas se 5432/5050 estiverem ocupadas no seu host
```

### 2. Subir o stack

```bash
docker compose up -d
```

### 3. Acessar o pgAdmin

- URL: <http://localhost:5050> (ou a porta que você definir em `PGADMIN_PORT`)
- Credenciais: as do `.env` (`PGADMIN_DEFAULT_EMAIL` / `PGADMIN_DEFAULT_PASSWORD`)

### 4. Cadastrar o servidor no pgAdmin

Em **Servers → Register → Server**:

- **General → Name**: `kubenews-db`
- **Connection → Host**: **`db`** (nome do serviço, **não** `localhost`)
- **Connection → Port**: `5432` (porta interna do container)
- **Connection → Maintenance database**: valor de `POSTGRES_DB`
- **Connection → Username**: valor de `POSTGRES_USER`
- **Connection → Password**: valor de `POSTGRES_PASSWORD`

> ⚠️ Dentro do container do pgAdmin, `localhost` é o próprio pgAdmin. Use o nome do serviço `db`.

## Arquitetura

```
                                                Host
                                                ┌──────────────────┐
┌────────────────────────────────────────────┐  │  App NodeJS      │
│         kubenews_net (bridge)              │  │  kube-news       │
│                                            │  │  localhost:5432  │
│  ┌──────────────────┐  ┌────────────────┐  │  │       │          │
│  │ kubenews-pgadmin │─>│ kubenews-db    │◄─┼──┼───────┘          │
│  │ pgadmin4:latest  │  │ postgres:16    │  │  │                  │
│  └────────┬─────────┘  └────────┬───────┘  │  │  navegador       │
└───────────┼────────────────────┼───────────┘  │  localhost:5050  │
            │ 5050:80             │ 5432:5432   │                  │
            └─────────────────────┴─────────────┘                  │
                                                └──────────────────┘

Volumes:  kubenews_postgres_data  →  /var/lib/postgresql/data
          kubenews_pgadmin_data   →  /var/lib/pgadmin
```

## Conectar a app NodeJS rodando no host

```env
DB_HOST=localhost
DB_PORT=5432             # ou o valor de POSTGRES_PORT no .env
DB_DATABASE=kubedevnews  # ou o valor de POSTGRES_DB
DB_USERNAME=kubedev      # ou o valor de POSTGRES_USER
DB_PASSWORD=<sua-senha>  # o valor de POSTGRES_PASSWORD
```

Rodar a app:

```bash
git clone https://github.com/KubeDev/kube-news.git
cd kube-news/src
npm install
# exporte as env vars acima
npm start
# → http://localhost:8080
```

## Recursos técnicos usados

| Recurso | Onde | Propósito |
|---|---|---|
| **`postgres:16`** | Serviço `db` | Versão major fixada (evita surpresas de upgrade) |
| **`dpage/pgadmin4:latest`** | Serviço `db_explorer` | Interface web oficial do pgAdmin |
| **Volume `postgres_data`** | `/var/lib/postgresql/data` | Cluster do Postgres inteiro persistido |
| **Volume `pgadmin_data`** | `/var/lib/pgadmin` | Conexões cadastradas do pgAdmin persistem |
| **Healthcheck `pg_isready`** | `db` | pgAdmin só sobe quando Postgres aceita conexões |
| **`PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED=False`** | `db_explorer` | Desliga wizard inicial (dev only) |
| **Escape `$$`** | Healthcheck com `pg_isready -U $$POSTGRES_USER` | Variável resolvida dentro do container |
| **Porta configurável** | `${POSTGRES_PORT:-5432}` | Fácil trocar se houver conflito no host |

## Prova de persistência

```bash
# 1. Cria dado real
docker compose exec db psql -U kubedev -d kubedevnews -c \
  "CREATE TABLE teste (id serial PRIMARY KEY, msg text);
   INSERT INTO teste (msg) VALUES ('sobreviveu ao down');"

# 2. Destrói containers (mantém volumes)
docker compose down

# 3. Confirma que volumes seguem vivos
docker volume ls | grep kubenews

# 4. Sobe de novo e consulta
docker compose up -d
sleep 15
docker compose exec db psql -U kubedev -d kubedevnews -c "SELECT * FROM teste;"
# → mostra a linha inserida ✅
```

Bonus — a **conexão do pgAdmin também persiste** (graças ao volume `pgadmin_data`). Depois do `down` + `up`, o servidor `kubenews-db` continua cadastrado na árvore.

## Comandos úteis

```bash
docker compose ps
docker compose logs -f db
docker compose logs -f db_explorer

# psql interativo
docker compose exec db psql -U kubedev -d kubedevnews

# Backup do banco
docker compose exec db pg_dump -U kubedev -d kubedevnews > backup.sql

# Restore
docker compose exec -T db psql -U kubedev -d kubedevnews < backup.sql
```

## Troubleshooting

| Erro | Solução |
|---|---|
| `port is already allocated` na 5432 | Outro Postgres rodando — mude `POSTGRES_PORT` no `.env` (ex: `5434`) |
| `port is already allocated` na 5050 | Outro pgAdmin rodando — mude `PGADMIN_PORT` no `.env` (ex: `5051`) |
| pgAdmin não conecta em `localhost` | Use `db` como hostname na conexão do pgAdmin |
| App NodeJS no host não conecta em `db` | Use `localhost` — o hostname `db` só existe dentro da rede Docker |
| `password authentication failed` | Senha do `.env` diverge da persistida no volume — `docker compose down -v` (⚠️ apaga dados) e recriar |
