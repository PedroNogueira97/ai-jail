#!/usr/bin/env bash
set -e

echo "🚀 Starting Gemini..."

# ==============================
# Validate environment
# ==============================

if [ -z "$GOOGLE_API_KEY" ]; then
  echo "❌ GOOGLE_API_KEY is not set"
  exit 1
fi

# ==============================
# CI / headless mode
# ==============================


  # Validate binary
  if ! command -v gemini >/dev/null 2>&1; then
    echo "❌ gemini not found"
    exit 1
  fi

  echo "✅ Gemini is installed and ready"
  exit 0
fi

# ==============================
# Start OpenClaude
# ==============================

echo "✅ Launching Gemini..."
exec gemini