# Docker Cheat Sheet 🐳

## Container-Befehle

### Grundlagen

```bash
# Container starten
docker run --name <name> -p <host>:<container> -e ENV=value <image>

# Laufende Container anzeigen
docker ps

# Alle Container anzeigen (auch gestoppte)
docker ps -a

# Container stoppen
docker stop <name>

# Container starten (existierend)
docker start <name>

# Container löschen
docker rm <name>

# Container force-löschen (auch laufend)
docker rm -f <name>
```

---

## Volume-Befehle

### Management

```bash
# Alle Volumes anzeigen
docker volume ls

# Volume erstellen
docker volume create <name>

# Volume-Details anzeigen
docker volume inspect <name>

# Volume löschen
docker volume rm <name>

# Alle ungenutzten Volumes löschen
docker volume prune
```

### Syntax beim docker run

```bash
# Named Volume
docker run -v <volume-name>:/container/path <image>

# Bind Mount
docker run -v /absoluter/host/pfad:/container/path <image>
```

**Merkregel:**

- Mappings (Volume, Port): Doppelpunkt `:`
- Env-Variablen: Gleichheitszeichen `=`

---

## Docker Compose

### Datei-Struktur

```yaml
version: '3.8'

services:
  servicename:
    image: postgres
    environment:
      KEY: value
    ports:
      - "host:container"
    volumes:
      - name:/container/path

volumes:
  name:
```

### Befehle

```bash
# Services starten (Hintergrund)
docker compose up -d

# Services stoppen (Container bleiben)
docker compose stop

# Services stoppen + Container löschen
docker compose down

# Services stoppen + Container + Volumes löschen
docker compose down -v

# Status anzeigen
docker compose ps

# Logs anzeigen (live)
docker compose logs -f

# Logs mit Limit
docker compose logs -f --tail=100

# Services neustarten (bei Code-Änderungen)
docker compose restart

# Neue Images pullen
docker compose pull

# Config validieren
docker compose config
```

---

## Häufige Container-Setups

### PostgreSQL

```bash
docker run --name postgres \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  -v pgdata:/var/lib/postgresql/data \
  postgres
```

### MySQL

```bash
docker run --name mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  mysql
```

### Redis

```bash
docker run --name redis \
  -p 6379:6379 \
  -v redis-data:/data \
  redis
```

---

## Service-Kommunikation in Compose

Container können sich über **Service-Namen** erreichen:

```yaml
services:
  db:
    image: postgres

  app:
    image: my-app
    # App kann DB erreichen via: jdbc:postgresql://db:5432/mydb
```

**Wichtig:** Service-Name = Hostname im Docker-Netzwerk

---

## Troubleshooting

### Port bereits belegt

```bash
# Prüfen welcher Container den Port nutzt
docker ps

# Anderen Port nutzen
docker run -p 5433:5432 postgres  # Host-Port 5433 statt 5432
```

### Volume in use

```bash
# Container zuerst entfernen
docker rm -f <container-name>

# Dann Volume löschen
docker volume rm <volume-name>
```

### Compose-Datei validieren

```bash
docker compose config
# Zeigt geparste YAML an oder Fehler
```

### Container-Logs anzeigen

```bash
# Einzelner Container
docker logs <container-name>

# Live following
docker logs -f <container-name>

# Compose Services
docker compose logs -f <service-name>
```

---

## Wichtige Unterscheidungen

| Befehl                   | Funktion                            |
|--------------------------|-------------------------------------|
| `docker ps`              | Nur laufende Container              |
| `docker ps -a`           | Alle Container                      |
| `docker volume ls`       | Alle Volumes                        |
| `docker volume inspect`  | Details eines Volumes               |
| `docker stop`            | Container stoppen (Daten bleiben)   |
| `docker rm`              | Container löschen                   |
| `docker compose down`    | Container löschen (Volumes bleiben) |
| `docker compose down -v` | Container + Volumes löschen         |

---

## Syntax-Regeln

### Named Volume vs Bind Mount

```bash
# Named Volume (kein Pfad-Präfix)
-v mydata:/container/path

# Bind Mount (beginnt mit / oder ./)
-v /home/user/data:/container/path
-v ./data:/container/path
```

### Flags-Reihenfolge

```bash
docker run [OPTIONS] IMAGE [COMMAND]
           ↑         ↑
           Flags     Image-Name

# Korrekt
docker run --name db -p 5432:5432 -v data:/data postgres

# Falsch
docker run --name db postgres -p 5432:5432  # ❌ Flags nach Image
```

---

## Quick Reference: Was macht was?

```bash
docker run      # Neuen Container erstellen + starten
docker start    # Existierenden Container starten
docker stop     # Container stoppen
docker restart  # Container neu starten
docker rm       # Container löschen
docker ps       # Container-Status
docker logs     # Container-Logs
docker exec     # Befehl in laufendem Container ausführen

docker volume ls       # Volumes auflisten
docker volume inspect  # Volume-Details
docker volume prune    # Ungenutzte Volumes löschen

docker compose up      # Services starten
docker compose down    # Services stoppen + löschen
docker compose ps      # Status der Services
docker compose logs    # Logs aller Services
```
