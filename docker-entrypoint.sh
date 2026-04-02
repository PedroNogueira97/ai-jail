#!/usr/bin/env bash
set -e

mkdir -p /home/dev/.config /home/dev/.memory /workspace

# Tenta garantir ownership quando possível
if command -v sudo >/dev/null 2>&1; then
  sudo chown -R dev:dev /home/dev/.config /home/dev/.memory /workspace 2>/dev/null || true
fi

exec "$@"