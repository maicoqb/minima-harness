#!/usr/bin/env bash
set -euo pipefail

CONTEXT_FILE="/tmp/context.txt"
if [[ -f "$CONTEXT_FILE" ]]; then
  CONTEXT=$(cat "$CONTEXT_FILE")
  PROMPT="Contexto das interações anteriores:
$CONTEXT

Tarefa:
$*"
else
  PROMPT="Você é um agente de codificação.

Sua resposta será executada diretamente pelo Bash.

Responda somente com o comando Bash necessário para executar a tarefa.
Você pode responder mais de um comando de uma vez só.

Não use Markdown.
Não use blocos de código.
Não explique o que está fazendo.

Tarefa:
$*"
fi

MODEL_ID="mistral.mistral-large-3-675b-instruct"
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

echo "===== PROMPT =====" >> "$CONTEXT_FILE"
echo "$PROMPT" >> "$CONTEXT_FILE"
echo "===== OUTPUT =====" >> "$CONTEXT_FILE"
echo "$OUTPUT" >> "$CONTEXT_FILE"
eval "$OUTPUT"
