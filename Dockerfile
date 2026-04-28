FROM ai-base:latest

USER root

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ARG UID=1000
ARG GID=1000

RUN groupadd -g ${GID} dev || true \
    && useradd -m -u ${UID} -g ${GID} -s /bin/bash dev || true

USER dev
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]