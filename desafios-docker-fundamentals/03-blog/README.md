# Desafio 03 — Blog Rota42 (WordPress + MySQL)

Stack Docker Compose que sobe **WordPress + MySQL** com persistência total de dados. Nada se perde ao destruir e recriar os containers.

## Missão

- Um serviço `wordpress` (imagem oficial)
- Um serviço `db` MySQL (imagem oficial)
- Persistência garantida em **ambos** os serviços via volumes nomeados
- Um único arquivo `compose.yaml` orquestrando tudo

## Entrega

```
03-blog/
├── compose.yaml       Orquestração
└── .env.example       Template das variáveis de ambiente
```

## Como executar

### 1. Configurar variáveis

```bash
cd desafios-docker-fundamentals/03-blog
cp .env.example .env
# opcional: edite .env para trocar as senhas
```

### 2. Subir o stack

```bash
docker compose up -d
```

### 3. Acessar

- **Blog**: <http://localhost:8080> (ou a porta que você definir em `WORDPRESS_HTTP_PORT`)
- Complete o wizard de instalação do WordPress
- Faça login e crie conteúdo (posts, uploads, etc.)

### 4. Parar

```bash
docker compose down          # preserva volumes (dados sobrevivem)
docker compose down -v       # ⚠️  APAGA volumes (perde tudo)
```

## Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                    rota42_blog_net (bridge)                 │
│                                                             │
│  ┌──────────────────────┐        ┌───────────────────────┐  │
│  │  rota42-wordpress    │───────>│  rota42-db            │  │
│  │  wordpress:latest    │  3306  │  mysql:8.0            │  │
│  └──────────┬───────────┘        └──────────┬────────────┘  │
└─────────────┼───────────────────────────────┼───────────────┘
              │ 8080:80                       │
              ▼                               ▼
         localhost:8080                ┌──────────────────┐
         (navegador)                   │ Volumes nomeados │
                                       │ rota42_db_data   │
                                       │ rota42_wp_data   │
                                       └──────────────────┘
```

## Recursos técnicos usados

| Recurso | Onde | Propósito |
|---|---|---|
| **Volumes nomeados** | `db_data`, `wp_data` | Persistência resistente a `docker compose down` |
| **Healthcheck** | `db` com `mysqladmin ping` | Garante que o MySQL está aceitando conexões |
| **`depends_on: service_healthy`** | `wordpress` depende de `db` | WordPress só sobe quando o banco está pronto |
| **Rede dedicada** | `rota42_blog_net` | Isolamento; WordPress acha o MySQL pelo hostname `db` |
| **Variáveis de ambiente** | `${VAR}` no `compose.yaml` + `.env` | Padrão 12-Factor — senhas fora do código |
| **Escape `$$`** | Healthcheck com `-p$$MYSQL_ROOT_PASSWORD` | Variável é resolvida **dentro** do container, senha não vaza |
| **`restart: unless-stopped`** | Ambos os serviços | Sobe sozinho após crash/reboot, respeita `stop` manual |

## Prova de persistência

```bash
# 1. Sobe e cria conteúdo pelo browser
docker compose up -d
# ... instala WP, cria post, faz upload de imagem

# 2. Destrói containers (mantém volumes)
docker compose down

# 3. Confirma que volumes seguem vivos
docker volume ls | grep rota42

# 4. Sobe de novo
docker compose up -d

# 5. Abre http://localhost:8080 → post e uploads ainda estão lá ✅
```

## Comandos úteis

```bash
docker compose ps                            # status dos serviços
docker compose logs -f wordpress             # logs do WordPress
docker compose logs -f db                    # logs do MySQL
docker compose exec db mysql -u wpuser -p    # entra no MySQL
docker compose restart wordpress             # reinicia só o WP
docker compose down -v --rmi all             # limpeza total ⚠️
```

## Troubleshooting

| Erro | Solução |
|---|---|
| `port is already allocated` na 8080 | Mude `WORDPRESS_HTTP_PORT` no `.env` |
| WordPress em "Error establishing a database connection" | Aguarde o healthcheck do MySQL — pode levar 30s no primeiro `up` |
| Senha mudada no `.env` mas não funciona | Volume `db_data` já tem a senha antiga baked in — `docker compose down -v` + `up -d` |
| Container `db` como `Exited (1)` | `docker compose logs db` — geralmente é conflito de dados no volume; `down -v` resolve |
