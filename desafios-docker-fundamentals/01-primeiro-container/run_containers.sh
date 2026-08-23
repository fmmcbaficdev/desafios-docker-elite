#!/usr/bin/env bash

# Desafio 1: O Primeiro Container da Rota42
# Script para demonstrar operações básicas com Docker

set -e:  # Parar em caso de erro
if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker daemon não está acessível. Inicie o Docker Desktop e tente novamente."
  exit 1
fi

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  Desafio 1: O Primeiro Container da Rota42              ║"
echo "╚══════════════════════════════════════════════════════════╝"

# 1. Baixar imagem
echo ""
echo "📥 [1/5] Baixando imagem Nginx..."
docker pull nginx:latest
echo "✅ Imagem nginx baixada"

# 2. Iniciar container
echo ""
echo "🚀 [2/5] Iniciando container 'meu-servidor'..."
docker run -d --name meu-servidor nginx:latest
echo "✅ Container iniciado"

# 3. Listar ativos
echo ""
echo "📋 [3/5] Containers em execução:"
docker ps

# 4. Parar container
echo ""
echo "⏹️  [4/5] Parando container..."
docker stop meu-servidor
echo "✅ Container parado"

# 5. Remover container
echo ""
echo "🗑️  [5/5] Removendo container..."
docker rm meu-servidor
echo "✅ Container removido"

# 6. Listar todos
echo ""
echo "📋 Todos os containers (incluindo parados):"
docker ps -a

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ✅ Desafio 1 Concluído com Sucesso!                     ║"
echo "╚══════════════════════════════════════════════════════════╝"