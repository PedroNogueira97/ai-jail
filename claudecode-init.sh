#!/usr/bin/env bash
set -e

echo "🚀 Starting Claude Code..."

if [ -z "$ANTHROPIC_API_KEY" ]; then
  echo "❌ ANTHROPIC_API_KEY is not set"
  exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "❌ claude command not found"
  echo "Available npm globals:"
  npm list -g --depth=0 || true
  exit 1
fi

echo "✅ Claude Code is installed and ready"
echo "✅ Launching Claude Code..."

exec claude