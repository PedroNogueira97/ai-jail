#!/usr/bin/env bash
set -e

mkdir -p /home/dev/.config /home/dev/.memory /workspace

# Tenta garantir ownership quando possível
if command -v sudo >/dev/null 2>&1; then
  sudo chown -R dev:dev /home/dev/.config /home/dev/.memory /workspace 2>/dev/null || true
fi

# Configura git automaticamente se variáveis existirem
if [ -n "${GIT_USER_NAME:-}" ]; then
  git config --global user.name "$GIT_USER_NAME"
fi

if [ -n "${GIT_USER_EMAIL:-}" ]; then
  git config --global user.email "$GIT_USER_EMAIL"
fi

# Define branch padrão (opcional mas recomendado)
git config --global init.defaultBranch main

exec "$@"