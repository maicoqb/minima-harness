#!/usr/bin/env bash
set -euo pipefail

PROMPT="Você é um agente de codificação.

Sua resposta será executada diretamente pelo Bash.

Responda somente com o comando Bash necessário para executar a tarefa.
Voce pode respoder mais de um comando de uma vez só.

Não use Markdown.
Não use blocos de código.
Não explique o que está fazendo.

Tarefa:
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
