# Desafio 01 — Primeiro Container

Script Bash que demonstra o ciclo de vida básico de um container Docker usando a imagem oficial do Nginx.

## Missão

- Baixar a imagem `nginx:latest`
- Iniciar um container chamado `meu-servidor`
- Listar containers em execução
- Parar e remover o container
- Listar todos os containers (incluindo os parados)

## Entrega

Script único em Bash:

```
01-primeiro-container/
└── run_containers.sh
```

## Como executar

### Git Bash (recomendado no Windows)

```bash
cd desafios-docker-fundamentals/01-primeiro-container
chmod +x run_containers.sh
./run_containers.sh
```

### PowerShell

```powershell
cd desafios-docker-fundamentals\01-primeiro-container
bash ./run_containers.sh
```

> ⚠️ Use `bash ./script.sh` (barra normal). `bash .\script.sh` (barra invertida) falha porque o Bash interpreta `\r` como escape.

## O que o script faz

1. **Pull** — `docker pull nginx:latest`
2. **Run** — `docker run -d --name meu-servidor nginx:latest`
3. **List** — `docker ps` (containers em execução)
4. **Stop** — `docker stop meu-servidor`
5. **Remove** — `docker rm meu-servidor`
6. **List all** — `docker ps -a` (todos, incluindo parados)

O `set -e` no topo garante que qualquer erro interrompe o script imediatamente.

## Saída esperada

```
╔══════════════════════════════════════════════════════════╗
║  Desafio 1: O Primeiro Container da Rota42              ║
╚══════════════════════════════════════════════════════════╝

📥 [1/5] Baixando imagem Nginx...
✅ Imagem nginx baixada

🚀 [2/5] Iniciando container 'meu-servidor'...
✅ Container iniciado

📋 [3/5] Containers em execução:
CONTAINER ID   IMAGE          ...   NAMES
xxxx           nginx:latest   ...   meu-servidor

⏹️  [4/5] Parando container...
✅ Container parado

🗑️  [5/5] Removendo container...
✅ Container removido

📋 Todos os containers (incluindo parados):
...

╔══════════════════════════════════════════════════════════╗
║  ✅ Desafio 1 Concluído com Sucesso!                     ║
╚══════════════════════════════════════════════════════════╝
```

## Troubleshooting

| Erro | Causa | Solução |
|---|---|---|
| `error during connect: ... pipe ...` | Docker Desktop parado | Iniciar Docker Desktop |
| `'\r': command not found` | Script salvo com CRLF | Converter para LF (Cursor: canto inferior direito) |
| `Conflict. The container name "/meu-servidor" is already in use` | Container antigo travado | `docker rm -f meu-servidor` e rodar de novo |
