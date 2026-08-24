# Desafio 02 — Container Logs (Persistência via Volume)

Script Bash que demonstra **persistência de dados com volumes Docker** — os logs do Nginx sobrevivem à destruição e recriação do container.

## Missão

- Criar um volume Docker chamado `nginx_logs`
- Executar um Nginx montando o volume em `/var/log/nginx` e expondo a porta **8080**
- Gerar logs com requisições `curl http://localhost:8080`
- Parar e remover o container
- Criar um **novo** container com o **mesmo volume** e comprovar que os logs antigos ainda existem

## Entrega

```
02-container-logs/
└── nginx_volume_container.sh
```

## Como executar

### Git Bash

```bash
cd desafios-docker-fundamentals/02-container-logs
chmod +x nginx_volume_container.sh
./nginx_volume_container.sh
```

### PowerShell

```powershell
cd desafios-docker-fundamentals\02-container-logs
bash ./nginx_volume_container.sh
```

## Fluxo do script (7 passos)

| # | Ação |
|---|---|
| 1 | Criar volume `nginx_logs` |
| 2 | Subir container `web-server` com volume montado em `/var/log/nginx` e porta `8080:80` |
| 3 | Gerar 5 requisições HTTP com `curl` |
| 4 | Verificar logs dentro do container e **contar linhas** do `access.log` |
| 5 | Parar e remover o container |
| 6 | Recriar container `web-server-new` com o **mesmo volume** |
| 7 | Comparar contagem de linhas — deve ser **igual ou maior** que antes |

Ao final, o script limpa o ambiente (`docker stop`, `docker rm`, `docker volume rm`).

## Recursos técnicos usados

- **`set -euo pipefail`** — falha rápido em qualquer erro
- **Limpeza defensiva no topo** — o script é idempotente (pode rodar N vezes seguidas)
- **`MSYS_NO_PATHCONV=1`** — desliga a conversão automática de paths do Git Bash (senão `/var/log/nginx` viraria `C:/Program Files/Git/var/log/nginx`)
- **Espera ativa** com `curl` em loop — não confia em `sleep` fixo
- **Validação forte de persistência** — compara `wc -l` do `access.log` antes e depois; falha com `exit 1` se não persistir

## Detalhe importante — symlinks do Nginx

A imagem oficial do Nginx faz um truque: os arquivos `access.log` e `error.log` são **symlinks para `/dev/stdout` e `/dev/stderr`**, para que os logs apareçam via `docker logs`. Isso **impede** que os logs sejam gravados em arquivo (e, portanto, no volume).

O script contorna isso:

```bash
docker exec web-server sh -c '
  rm -f /var/log/nginx/access.log /var/log/nginx/error.log
  nginx -s reopen
'
```

Removemos os symlinks e mandamos o Nginx **reabrir** os arquivos de log — ele cria arquivos reais no lugar, que agora vivem no volume.

## Saída esperada

```
📊 Comparação:
  ├─ Linhas antes  : 5
  └─ Linhas depois : 5
✅ SUCESSO! Logs antigos preservados (5 linhas)
```

## Troubleshooting

| Erro | Solução |
|---|---|
| `port is already allocated` | Alguém usando 8080 — pare o outro serviço ou edite a porta no script |
| `bash: ./nginx_volume_container.sh: Permission denied` | `chmod +x nginx_volume_container.sh` |
| `❌ FALHA! Logs não persistiram` | Verifique se o `converter_logs_em_arquivo` executou sem erro (Nginx precisa estar `ready` antes) |
