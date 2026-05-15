# Velocity-CTD Docker Image

[![Build and push Docker image](https://github.com/sokolovskiyoleg/velocity-ctd/actions/workflows/docker.yaml/badge.svg)](https://github.com/sokolovskiyoleg/velocity-ctd/actions/workflows/docker.yaml)

Docker image for [Velocity-CTD](https://github.com/GemstoneGG/Velocity-CTD) - a fork of Velocity with various optimizations, commands, and more.

## What is Velocity-CTD?

Velocity-CTD is a Minecraft server proxy with unparalleled server support, scalability, and flexibility. It's a fork of Velocity with additional features:

- Redis database support for multi-proxy setups
- Advanced queue system
- Built-in commands (/alert, /find, /gkick, /gip, /ping, /plist, /send, /transfer, etc.)
- Fallback servers
- And more...

## How to use this image

### Start a Velocity-CTD server

```bash
docker run -p 25565:25565 -v /path/to/data:/data sokolovskiyoleg/velocity-ctd:latest
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `JAVA_MEMORY` | JVM memory (e.g., 512M, 1G) | 512M |
| `JAVA_FLAGS` | Additional JVM flags | (optimized defaults) |
| `VELOCITY_VERSION` | Specific version or "latest" | latest |
| `VELOCITY_PORT` | Proxy port | 25565 |
| `RCON_PORT` | RCON port | 25575 |
| `RCON_PASSWORD` | RCON password | minecraft |
| `PUID` | User ID for file ownership | 1000 |
| `PGID` | Group ID for file ownership | 1000 |

### Volumes

- `/data` - Configuration and data files

### Ports

- `25565` - Minecraft proxy
- `25575` - RCON

## Build locally

```bash
docker build -t velocity-ctd:test .
```