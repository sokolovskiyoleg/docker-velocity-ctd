# Velocity-CTD Docker Image

🌐 [Русский](README.ru.md)

Docker image for [Velocity-CTD](https://github.com/GemstoneGG/Velocity-CTD) — a Minecraft server proxy fork with Redis support, advanced queue system, and built-in commands.

## Quick Start

### Docker Run

```bash
docker run -d -p 25565:25565 -v $(pwd)/data:/data osn298/velocity-ctd:latest
```

### Docker Compose

```yaml
services:
  velocity:
    image: osn298/velocity-ctd:latest
    ports:
      - "25565:25565"
    volumes:
      - ./data:/data
    environment:
      JAVA_MEMORY: 1G
      RCON_PASSWORD: your-secure-password
    restart: unless-stopped
```

## Image Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest release |
| `build-xxx` | Specific version (e.g. `build-233`) |

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `JAVA_MEMORY` | JVM memory (e.g. `512M`, `1G`) | `512M` |
| `JAVA_FLAGS` | Additional JVM flags | Optimized defaults |
| `VELOCITY_PORT` | Proxy port | `25565` |
| `RCON_PORT` | RCON port | `25575` |
| `RCON_PASSWORD` | RCON password | `minecraft` |

### Volumes

| Path | Purpose |
|------|---------|
| `/data` | `velocity.toml`, plugins, logs, and other data |

### Ports

| Port | Purpose |
|------|---------|
| `25565` | Minecraft proxy |
| `25575` | RCON |

## Build

### Latest version

```bash
docker build -t velocity-ctd:test .
```

### Specific version

```bash
docker build --build-arg VELOCITY_VERSION=build-233 -t velocity-ctd:test .
```

## Security

- Container runs as non-root user (UID 1000)
- Bind mount `/data` must be owned by UID 1000 on the host

## License

GPL-3.0
