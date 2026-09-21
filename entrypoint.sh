#!/bin/sh

VELOCITY_PORT=${VELOCITY_PORT:-25565}
RCON_PORT=${RCON_PORT:-25575}
RCON_PASSWORD=${RCON_PASSWORD:-minecraft}

VELOCITY_JAR="/opt/velocity-ctd/velocity-ctd.jar"

if [ ! -f "$VELOCITY_JAR" ]; then
    echo "JAR not found"
    exit 1
fi

if ! touch /data/.write-test 2>/dev/null; then
    echo "ERROR: /data is not writable. Mount it owned by UID 1000, e.g.: chown -R 1000:1000 ./velocity"
    exit 1
fi
rm -f /data/.write-test

ensure_config() {
    if [ -f /data/velocity.toml ] && { grep -q "^online-mode" /data/velocity.toml \
        || [ "$(wc -c < /data/velocity.toml)" -ge 20000 ]; }; then
        return
    fi

    rm -f /data/velocity.toml /data/velocity.toml.tmp
    echo "Generating velocity.toml..."
    java -jar "$VELOCITY_JAR" >/tmp/velocity-generate.log 2>&1 &
    VELOCITY_PID=$!

    TIMEOUT=600
    while [ $TIMEOUT -gt 0 ]; do
        grep -q "Done" /tmp/velocity-generate.log && break
        sleep 0.5
        TIMEOUT=$((TIMEOUT - 1))
    done

    kill $VELOCITY_PID 2>/dev/null
    wait $VELOCITY_PID 2>/dev/null

    if ! grep -q "Done" /tmp/velocity-generate.log; then
        echo "ERROR: failed to generate velocity.toml within $((600 - TIMEOUT))s" >&2
        exit 1
    fi
    echo "velocity.toml generated"
}

ensure_config

# Apply env vars to config
rm -f /data/velocity.toml.tmp
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
