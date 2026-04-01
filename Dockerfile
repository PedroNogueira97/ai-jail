FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Base + deps
RUN apt update && apt install -y \
    curl \
    git \
    vim \
    nano \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    sudo \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Node 20 (mais confiável)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt install -y nodejs \
    && npm config set registry https://registry.npmjs.org/

# Instala globais como ROOT (evita erro de permissão)
# basic-memory exige Python 3.12+; Ubuntu 24.04 + --break-system-packages (PEP 668)
RUN npm install -g @google/gemini-cli@latest --unsafe-perm=true \
    && pip3 install --break-system-packages basic-memory

# Usuário não-root
RUN useradd -ms /bin/bash dev && \
    usermod -aG sudo dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER dev
WORKDIR /workspace

# Pastas padrão
RUN mkdir -p /workspace /home/dev/.config /home/dev/.memory

ENV MEMORY_PATH=/home/dev/.memory

CMD ["bash"]