#!/bin/sh

# Verifica se os argumentos foram passados corretamente
if [ "$#" -ne 2 ]; then
    echo "Uso: convert.sh <arquivo de entrada> <formato de saída>"
    echo "Exemplo: convert.sh video.mp4 avi"
    exit 1
fi

INPUT_FILE=$1
OUTPUT_FORMAT=$2
OUTPUT_FILE="output.$OUTPUT_FORMAT"

# Verifica se o arquivo de entrada existe
if [ ! -f "$INPUT_FILE" ]; then
    echo "Erro: O arquivo '$INPUT_FILE' não foi encontrado!"
    exit 1
fi

# Executa a conversão com FFmpeg
echo "Iniciando conversão de '$INPUT_FILE' para '$OUTPUT_FILE'..."
ffmpeg -i "$INPUT_FILE" -preset fast -c:v libx264 -c:a aac "$OUTPUT_FILE"

# Verifica se a conversão foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "Conversão concluída com sucesso! Arquivo gerado: $OUTPUT_FILE"
else
    echo "Erro na conversão do arquivo."
    exit 1
fi
