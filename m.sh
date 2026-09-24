#!/usr/bin/env bash
set -euo pipefail

PROMPT="Você é um agente de codificação.
Tudo que você retornar será executado via bash.
Retorne como reposta apenas um comando bash válido.
Não retorne markdowns, comentários ou explicações.

Execute a tarefa:
$*"
MODEL_ID="qwen.qwen3-coder-30b-a3b-v1:0"
REGION="${AWS_DEFAULT_REGION:-sa-east-1}"

echo "===== chamando modelo ===="

RESP=$(aws bedrock-runtime converse \
  --region "$REGION" \
  --model-id "$MODEL_ID" \
  --messages "[{\"role\":\"user\",\"content\":[{\"text\":$(jq -Rs . <<<"$PROMPT")}]}]" \
  --inference-config maxTokens=512,temperature=0)

# Extrai o texto da resposta
OUTPUT=$(jq -r '.output.message.content[0].text' <<<"$RESP")

echo "=== resposta do modelo ==="
echo "$OUTPUT"
echo "=========================="

eval "$OUTPUT"
