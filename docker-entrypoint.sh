#!/usr/bin/env bash
set -e

# Corrige workspace/home
chown -R dev:dev /workspace /home/dev 2>/dev/null || true

# Prepara SSH para GitHub
rm -rf /home/dev/.ssh
mkdir -p /home/dev/.ssh

if [ -f /ssh-host/id_ed25519 ]; then
  cp /ssh-host/id_ed25519 /home/dev/.ssh/id_ed25519
else
  echo "Aviso: /ssh-host/id_ed25519 não encontrado"
fi

if [ -f /ssh-host/id_ed25519.pub ]; then
  cp /ssh-host/id_ed25519.pub /home/dev/.ssh/id_ed25519.pub
else
  echo "Aviso: /ssh-host/id_ed25519.pub não encontrado"
fi

ssh-keyscan github.com > /home/dev/.ssh/known_hosts 2>/dev/null || true

chown -R dev:dev /home/dev/.ssh
chmod 700 /home/dev/.ssh
chmod 600 /home/dev/.ssh/id_ed25519 2>/dev/null || true
chmod 644 /home/dev/.ssh/id_ed25519.pub 2>/dev/null || true
chmod 644 /home/dev/.ssh/known_hosts

# Git global do usuário dev
su dev -c "git config --global user.name '${GIT_USER_NAME}'"
su dev -c "git config --global user.email '${GIT_USER_EMAIL}'"
su dev -c "git config --global init.defaultBranch main"
su dev -c "git config --global url.'git@github.com:'.insteadOf 'https://github.com/'"

# Executa o comando original como dev
exec runuser -u dev -- "$@"