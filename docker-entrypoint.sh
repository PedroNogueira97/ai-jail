#!/usr/bin/env bash
set -e

mkdir -p /home/dev/.config/git /workspace
export GIT_CONFIG_GLOBAL=/home/dev/.config/git/config

if [ -n "${GIT_USER_NAME:-}" ]; then
  git config --global user.name "$GIT_USER_NAME" || echo "Aviso: não foi possível definir git user.name"
fi

if [ -n "${GIT_USER_EMAIL:-}" ]; then
  git config --global user.email "$GIT_USER_EMAIL" || echo "Aviso: não foi possível definir git user.email"
fi

git config --global init.defaultBranch main || echo "Aviso: não foi possível definir init.defaultBranch"

exec "$@"