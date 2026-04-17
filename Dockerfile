FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=dev
ENV HOME=/home/dev
ENV WORKSPACE=/workspace

RUN apt update && apt install -y \
    software-properties-common \
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
    apt-transport-https \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get update && apt-get install -y \
    php8.3 \
    php8.3-cli \
    php8.3-common \
    php8.3-mysql \
    php8.3-xml \
    php8.3-curl \
    php8.3-mbstring \
    php8.3-zip \
    php8.3-intl \
    php8.3-bcmath \
    php8.3-opcache \
    php8.3-sqlite3 \
    mysql-client \
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

RUN useradd -m -s /bin/bash dev \
    && usermod -aG sudo dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

RUN mkdir -p /home/dev/.ssh /home/dev/.config /workspace \
&& chown -R dev:dev /home/dev /workspace

# Composer
RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php \
    && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm /tmp/composer-setup.php

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh


USER dev
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]