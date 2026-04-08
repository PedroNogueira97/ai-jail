#!/usr/bin/env bash
set -e

echo "🚀 Starting OpenClaude..."

# ==============================
# Validate environment
# ==============================

if [ -z "$OPENAI_API_KEY" ]; then
  echo "❌ OPENAI_API_KEY is not set"
  exit 1
fi

if [ -z "$OPENAI_MODEL" ]; then
  echo "❌ OPENAI_MODEL is not set"
  exit 1
fi

# ==============================
# Debug info (important)
# ==============================

echo "🧠 Provider: OpenAI-compatible"
echo "📦 Model: $OPENAI_MODEL"
echo "🌐 Base URL: ${OPENAI_BASE_URL:-https://api.openai.com/v1}"
echo "📁 Workspace: $(pwd)"

# ==============================
# CI / headless mode
# ==============================

if [ "${OPENCLAUDE_HEADLESS:-0}" = "1" ]; then
  echo "⚙️ Running in headless mode (CI)"

  # Validate binary
  if ! command -v openclaude >/dev/null 2>&1; then
    echo "❌ openclaude not found"
    exit 1
  fi

  echo "✅ OpenClaude is installed and ready"
  exit 0
fi

# ==============================
# Start OpenClaude
# ==============================

echo "✅ Launching OpenClaude..."
exec openclaude