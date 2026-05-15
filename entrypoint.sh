#!/bin/sh

VELOCITY_PORT=${VELOCITY_PORT:-25565}
RCON_PORT=${RCON_PORT:-25575}
RCON_PASSWORD=${RCON_PASSWORD:-minecraft}

VELOCITY_JAR="/opt/velocity-ctd/velocity-ctd.jar"

if [ ! -f "$VELOCITY_JAR" ]; then
    echo "JAR not found"
    exit 1
fi

if [ ! -f /data/velocity.toml ]; then
    echo "Creating default velocity.toml..."
    cat > /data/velocity.toml << EOF
config-version = "1.0"
bind = "0.0.0.0:${VELOCITY_PORT}"
motd = "&3Velocity-CTD Server"
show-max-players = 500
online-mode = true

[servers]
lobby = "vanilla:25566"

[forced-hosts]

[query]
enabled = false

[rcon]
enabled = true
bind = "0.0.0.0"
port = ${RCON_PORT}
password = "${RCON_PASSWORD}"

[metrics]
enabled = true
EOF
    echo "velocity.toml created at /data/velocity.toml"
fi

exec java \
    -Xms$JAVA_MEMORY \
    -Xmx$JAVA_MEMORY \
    $JAVA_FLAGS \
    -jar "$VELOCITY_JAR"
