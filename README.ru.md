# Docker-образ Velocity-CTD

🌐 [English](README.md)

Docker-образ для [Velocity-CTD](https://github.com/GemstoneGG/Velocity-CTD) — форка Minecraft-прокси с поддержкой Redis, продвинутой системой очередей и встроенными командами.

## Быстрый старт

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

## Теги образов

| Тег | Описание |
|-----|----------|
| `latest` | Последняя версия |
| `build-xxx` | Конкретная версия (например `build-233`) |

## Конфигурация

### Переменные окружения

| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `JAVA_MEMORY` | Память JVM (например `512M`, `1G`) | `512M` |
| `JAVA_FLAGS` | Дополнительные флаги JVM | Оптимизированные |
| `VELOCITY_PORT` | Порт прокси | `25565` |
| `RCON_PORT` | Порт RCON | `25575` |
| `RCON_PASSWORD` | Пароль RCON | `minecraft` |

### Тома

| Путь | Назначение |
|------|------------|
| `/data` | `velocity.toml`, плагины, логи и другие данные |

### Порты

| Порт | Назначение |
|------|------------|
| `25565` | Minecraft прокси |
| `25575` | RCON |

## Сборка

### Последняя версия

```bash
docker build -t velocity-ctd:test .
```

### Конкретная версия

```bash
docker build --build-arg VELOCITY_VERSION=build-233 -t velocity-ctd:test .
```

## Безопасность

- Контейнер работает от непривилегированного пользователя (UID 1000)
- Bind mount `/data` на хосте должен принадлежать UID 1000

## Лицензия

GPL-3.0
