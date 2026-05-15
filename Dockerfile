ARG TARGETPLATFORM
ARG TARGETARCH
FROM --platform=${TARGETPLATFORM:-linux/amd64} eclipse-temurin:21-jre-alpine

LABEL org.opencontainers.image.vendor="Dockcenter"
LABEL org.opencontainers.image.title="Velocity-CTD"
LABEL org.opencontainers.image.description="Docker image for Velocity-CTD fork"
LABEL org.opencontainers.image.documentation="https://github.com/sokolovskiyoleg/docker-velocity-ctd"
LABEL org.opencontainers.image.authors="Oleg Sokolovskiy"
LABEL org.opencontainers.image.source="https://github.com/sokolovskiyoleg/docker-velocity-ctd"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.architecture="${TARGETARCH}"

ENV JAVA_MEMORY="512M"
ENV JAVA_FLAGS="-XX:+UseStringDeduplication -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch"
ENV PUID=1000
ENV PGID=1000
ENV VELOCITY_VERSION="latest"
ENV VELOCITY_PORT="25565"
ENV RCON_HOST="0.0.0.0"
ENV RCON_PORT="25575"

RUN apk add --no-cache --upgrade openssl shadow wget curl && \
    rm -rf /var/cache/apk/* /tmp/*

COPY --from=tianon/gosu /gosu /usr/local/bin/

RUN mkdir -p /data /opt/velocity-ctd /tmp/velocity-ctd && \
    wget -q -O /opt/velocity-ctd/velocity-ctd.jar \
    "https://github.com/GemstoneGG/Velocity-CTD/releases/download/build-229/velocity-ctd-3.5.0-SNAPSHOT-229.jar"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /data
EXPOSE ${VELOCITY_PORT} ${RCON_PORT}

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD nc -z localhost ${VELOCITY_PORT:-25565} || exit 1

WORKDIR /data

ENTRYPOINT ["/entrypoint.sh"]