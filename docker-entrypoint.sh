#!/usr/bin/env bash
set -e

# Corrige permissões principais
chown -R dev:dev /workspace /home/dev 2>/dev/null || true

# Configura SSH do GitHub dentro do container
rm -rf /home/dev/.ssh
mkdir -p /home/dev/.ssh

if [ -f /ssh-host/id_ed25519 ]; then
  cp /ssh-host/id_ed25519 /home/dev/.ssh/id_ed25519
fi

if [ -f /ssh-host/id_ed25519.pub ]; then
  cp /ssh-host/id_ed25519.pub /home/dev/.ssh/id_ed25519.pub
fi

ssh-keyscan github.com > /home/dev/.ssh/known_hosts 2>/dev/null || true

chown -R dev:dev /home/dev/.ssh
chmod 700 /home/dev/.ssh
chmod 600 /home/dev/.ssh/id_ed25519 2>/dev/null || true
chmod 644 /home/dev/.ssh/id_ed25519.pub 2>/dev/null || true
chmod 644 /home/dev/.ssh/known_hosts

# Configura Git global
if [ -n "${GIT_USER_NAME:-}" ]; then
  su dev -c "git config --global user.name \"$GIT_USER_NAME\"" || echo "Aviso: não foi possível definir git user.name"
fi

if [ -n "${GIT_USER_EMAIL:-}" ]; then
  su dev -c "git config --global user.email \"$GIT_USER_EMAIL\"" || echo "Aviso: não foi possível definir git user.email"
fi

su dev -c "git config --global init.defaultBranch main" || echo "Aviso: não foi possível definir init.defaultBranch"
su dev -c "git config --global url.\"git@github.com:\".insteadOf \"https://github.com/\"" || echo "Aviso: não foi possível configurar GitHub SSH"

exec "$@"