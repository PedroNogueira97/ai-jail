FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=dev
ENV HOME=/home/dev
ENV WORKSPACE=/workspace
ENV MEMORY_PATH=/home/dev/.memory

RUN apt update && apt install -y \
    bash \
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
    openssh-client \
    ripgrep \
    findutils \
    coreutils \
    fd-find \
    grep \
    sed \
    gawk \
    tree \
    jq \
    && ln -s $(which fdfind) /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt install -y nodejs \
    && npm config set registry https://registry.npmjs.org/ \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
    && apt update \
    && apt install -y gh \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages basic-memory

RUN useradd -m -s /bin/bash dev \
    && usermod -aG sudo dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

RUN mkdir -p /workspace /home/dev/.config /home/dev/.memory /home/dev/.ssh \
    && chown -R dev:dev /workspace /home/dev \
    && chmod 700 /home/dev/.ssh

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER dev
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]