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
awk -v port="$VELOCITY_PORT" '
  /^bind = / && !done_bind {
    print "bind = \"0.0.0.0:" port "\""
    done_bind = 1
    next
  }
  { print }
' /data/velocity.toml > /data/velocity.toml.tmp && mv /data/velocity.toml.tmp /data/velocity.toml

# Update or add RCON section
if grep -q '^\[rcon\]' /data/velocity.toml; then
    sed -i "s/^port = .*/port = ${RCON_PORT}/" /data/velocity.toml
    sed -i 's/^password = .*/password = "'"${RCON_PASSWORD}"'"/' /data/velocity.toml
else
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
