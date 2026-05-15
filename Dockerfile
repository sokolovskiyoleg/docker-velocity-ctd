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

ARG VELOCITY_VERSION=latest
ENV JAVA_MEMORY="512M"
ENV JAVA_FLAGS="-XX:+UseStringDeduplication -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch"
ENV PUID=1000
ENV PGID=1000
ENV VELOCITY_PORT="25565"
ENV RCON_HOST="0.0.0.0"
ENV RCON_PORT="25575"

RUN apk add --no-cache openssl shadow wget coreutils && \
    mkdir -p /opt/velocity-ctd && \
    if [ "${VELOCITY_VERSION}" = "latest" ]; then \
        API_URL="https://api.github.com/repos/GemstoneGG/Velocity-CTD/releases/latest"; \
    else \
        API_URL="https://api.github.com/repos/GemstoneGG/Velocity-CTD/releases/tags/${VELOCITY_VERSION}"; \
    fi && \
    RELEASE=$(wget -qO- "$API_URL") && \
    TAG=$(echo "$RELEASE" | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"//;s/"//') && \
    SHA256=$(echo "$RELEASE" | grep -o '"digest": *"[^"]*"' | sed 's/"digest": *"//;s/"//' | sed 's/sha256://') && \
    echo "Downloading Velocity-CTD $TAG..." && \
    wget -q -O /opt/velocity-ctd/velocity-ctd.jar \
      "https://github.com/GemstoneGG/Velocity-CTD/releases/download/${TAG}/velocity-ctd-3.5.0-SNAPSHOT-${TAG#build-}.jar" && \
    echo "${SHA256}  /opt/velocity-ctd/velocity-ctd.jar" | sha256sum -c -

COPY --from=tianon/gosu /gosu /usr/local/bin/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /data
EXPOSE ${VELOCITY_PORT} ${RCON_PORT}

WORKDIR /data

ENTRYPOINT ["/entrypoint.sh"]