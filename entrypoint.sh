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
    echo "Generating velocity.toml..."
    java -jar "$VELOCITY_JAR" &
    VELOCITY_PID=$!

    TIMEOUT=30
    while [ ! -f /data/velocity.toml ] && [ $TIMEOUT -gt 0 ]; do
        sleep 0.5
        TIMEOUT=$((TIMEOUT - 1))
    done

    kill $VELOCITY_PID 2>/dev/null
    wait $VELOCITY_PID 2>/dev/null
    echo "velocity.toml generated"
fi

# Apply env vars to config
sed -i "s/^bind = .*/bind = \"0.0.0.0:${VELOCITY_PORT}\"/" /data/velocity.toml

# Add RCON section if not present
if ! grep -q '^\[rcon\]' /data/velocity.toml; then
    cat >> /data/velocity.toml << EOF

[rcon]
enabled = true
bind = "0.0.0.0"
port = ${RCON_PORT}
password = "${RCON_PASSWORD}"
EOF
fi

exec mc-server-runner -stop-command "end" java \
    -Xms$JAVA_MEMORY \
    -Xmx$JAVA_MEMORY \
    $JAVA_FLAGS \
    -jar "$VELOCITY_JAR"
