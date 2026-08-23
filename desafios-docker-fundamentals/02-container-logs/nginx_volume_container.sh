#!/usr/bin/env bash

# Desafio 2: Container com Logs Persistentes
# Script para demonstrar volumes Docker

set -euo pipefail

# Desabilita conversão automática de paths do MSYS2/Git Bash no Windows.
# Sem isso, "/var/log/nginx" vira "C:/Program Files/Git/var/log/nginx"
# antes de chegar no docker exec. Ignorado em Linux/WSL.
export MSYS_NO_PATHCONV=1

# ── Limpeza defensiva (idempotência) ────────────────────────────────
# Garante que o script pode ser executado várias vezes seguidas,
# mesmo se a execução anterior travou no meio.
docker rm -f web-server web-server-new 2>/dev/null || true
docker volume rm nginx_logs 2>/dev/null || true

# ── Helpers ─────────────────────────────────────────────────────────

# Espera o Nginx aceitar conexões em http://localhost:8080
aguardar_nginx() {
  local tentativas=15
  for i in $(seq 1 "$tentativas"); do
    if curl -sf http://localhost:8080 > /dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "❌ Nginx não respondeu em ${tentativas}s"
  return 1
}

# Conta linhas do access.log dentro de um container
contar_acessos() {
  local container="$1"
  docker exec "$container" sh -c 'wc -l < /var/log/nginx/access.log 2>/dev/null || echo 0' | tr -d ' '
}

# A imagem oficial do Nginx faz um "truque": os arquivos access.log e
# error.log são symlinks para /dev/stdout e /dev/stderr, para que os logs
# apareçam via `docker logs`. Isso IMPEDE que os logs sejam gravados no
# volume. Para o desafio de persistência, removemos os symlinks e mandamos
# o Nginx reabrir os arquivos — ele cria arquivos reais no lugar.
converter_logs_em_arquivo() {
  local container="$1"
  docker exec "$container" sh -c '
    rm -f /var/log/nginx/access.log /var/log/nginx/error.log
    nginx -s reopen
  '
}

# ── Cabeçalho ───────────────────────────────────────────────────────
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  Desafio 2: Container com Logs Persistentes             ║"
echo "╚══════════════════════════════════════════════════════════╝"

# ── 1. Criar volume ─────────────────────────────────────────────────
echo ""
echo "💾 [1/7] Criando volume 'nginx_logs'..."
docker volume create nginx_logs
echo "✅ Volume criado"

# ── 2. Iniciar container com volume ─────────────────────────────────
echo ""
echo "🚀 [2/7] Iniciando Nginx com volume montado..."
docker run -d \
  --name web-server \
  -p 8080:80 \
  -v nginx_logs:/var/log/nginx \
  nginx:latest > /dev/null
echo "✅ Container iniciado (porta 8080)"

echo "⏳ Aguardando Nginx ficar pronto..."
aguardar_nginx
echo "✅ Nginx respondendo"

echo "🔧 Configurando Nginx para gravar logs em arquivo (não em stdout)..."
converter_logs_em_arquivo web-server
echo "✅ Logs agora são gravados em /var/log/nginx/*.log"

# ── 3. Gerar logs ───────────────────────────────────────────────────
echo ""
echo "📊 [3/7] Gerando logs com requisições HTTP..."
for i in {1..5}; do
  curl -s http://localhost:8080 > /dev/null
  echo "  └─ Requisição $i concluída"
done
echo "✅ Logs gerados"

# ── 4. Verificar logs (antes de destruir) ───────────────────────────
echo ""
echo "📂 [4/7] Verificando logs no container:"
docker exec web-server ls -lh /var/log/nginx/
LINHAS_ANTES=$(contar_acessos web-server)
echo "📈 Linhas em access.log: ${LINHAS_ANTES}"
echo "✅ Logs visíveis"

# ── 5. Parar e remover ──────────────────────────────────────────────
echo ""
echo "⏹️  [5/7] Parando e removendo container..."
docker stop web-server > /dev/null
docker rm web-server > /dev/null
echo "✅ Container removido"

# ── 6. Recriar com mesmo volume ─────────────────────────────────────
echo ""
echo "🔄 [6/7] Recriando container com mesmo volume..."
docker run -d \
  --name web-server-new \
  -p 8080:80 \
  -v nginx_logs:/var/log/nginx \
  nginx:latest > /dev/null

echo "⏳ Aguardando novo Nginx ficar pronto..."
aguardar_nginx
echo "✅ Novo container ativo"

# ── 7. Validar persistência ─────────────────────────────────────────
echo ""
echo "📂 [7/7] Verificando persistência de logs:"
docker exec web-server-new ls -lh /var/log/nginx/
LINHAS_DEPOIS=$(contar_acessos web-server-new)

echo ""
echo "📊 Comparação:"
echo "  ├─ Linhas antes  : ${LINHAS_ANTES}"
echo "  └─ Linhas depois : ${LINHAS_DEPOIS}"

if [ "$LINHAS_DEPOIS" -ge "$LINHAS_ANTES" ] && [ "$LINHAS_ANTES" -gt 0 ]; then
  echo "✅ SUCESSO! Logs antigos preservados (${LINHAS_ANTES} linhas)"
else
  echo "❌ FALHA! Logs não persistiram (antes=${LINHAS_ANTES}, depois=${LINHAS_DEPOIS})"
  exit 1
fi

# ── Cleanup ─────────────────────────────────────────────────────────
echo ""
echo "🧹 Limpando ambiente..."
docker stop web-server-new > /dev/null
docker rm web-server-new > /dev/null
docker volume rm nginx_logs > /dev/null
echo "✅ Ambiente limpo"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ✅ Desafio 2 Concluído com Sucesso!                     ║"
echo "╚══════════════════════════════════════════════════════════╝"
