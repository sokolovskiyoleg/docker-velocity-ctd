#!/bin/sh

PUID=${PUID:-1000}
PGID=${PGID:-1000}

if [ -d /data ] && [ "$(ls -A /data 2>/dev/null)" ]; then
    PUID=$(stat -c %u /data 2>/dev/null || echo "1000")
    PGID=$(stat -c %g /data 2>/dev/null || echo "1000")
    echo "Detected data directory owner: UID=$PUID, GID=$PGID"
fi

VELOCITY_PORT=${VELOCITY_PORT:-25565}
RCON_PORT=${RCON_PORT:-25575}
RCON_PASSWORD=${RCON_PASSWORD:-minecraft}

VELOCITY_JAR="/opt/velocity-ctd/velocity-ctd.jar"
mkdir -p /opt/velocity-ctd /data

if [ ! -f "$VELOCITY_JAR" ]; then
    echo "JAR not found, please rebuild with VELOCITY_VERSION"
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

TARGET_USER=$(getent passwd "$PUID" | cut -d: -f1)
if [ -n "$TARGET_USER" ] && [ "$TARGET_USER" != "velocity-ctd" ]; then
    echo "UID $PUID already belongs to user '$TARGET_USER', using existing user"
    RUN_AS_USER="$TARGET_USER"
elif getent passwd velocity-ctd > /dev/null 2>&1; then
    EXISTING_UID=$(getent passwd velocity-ctd | cut -d: -f3)
    if [ "$EXISTING_UID" != "$PUID" ]; then
        if getent passwd "$PUID" > /dev/null 2>&1; then
            echo "UID $PUID is taken, keeping existing velocity-ctd user (UID: $EXISTING_UID)"
        else
            usermod -u $PUID velocity-ctd
        fi
    fi
    RUN_AS_USER="velocity-ctd"
else
    if getent group velocity-ctd > /dev/null 2>&1; then
        groupmod -g $PGID velocity-ctd
    else
        addgroup -g $PGID velocity-ctd
    fi
    adduser -u $PUID -S -G velocity-ctd velocity-ctd
    RUN_AS_USER="velocity-ctd"
fi

if [ -z "$RUN_AS_USER" ]; then
    RUN_AS_USER="velocity-ctd"
fi

chown -R $RUN_AS_USER:velocity-ctd /data
chown -R $RUN_AS_USER:velocity-ctd /opt/velocity-ctd

exec gosu $RUN_AS_USER java \
    -Xms$JAVA_MEMORY \
    -Xmx$JAVA_MEMORY \
    $JAVA_FLAGS \
    -jar "$VELOCITY_JAR"