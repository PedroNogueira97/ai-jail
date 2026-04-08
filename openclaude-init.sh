#!/usr/bin/env bash
set -e

echo "Starting OpenClaude with OpenRouter..."
echo "Model: ${OPENAI_MODEL:-not-set}"
echo "Base URL: ${OPENAI_BASE_URL:-not-set}"

if [ "${OPENCLAUDE_HEADLESS:-0}" = "1" ]; then
  echo "Headless mode enabled. Exiting after validation."
  command -v openclaude >/dev/null 2>&1
  exit 0
fi

exec openclaude