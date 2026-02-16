# Image Management

## Was sind Docker Images?

Ein **Docker Image** ist eine unveränderliche Vorlage für Container. Es enthält:
- Betriebssystem-Layer
- Laufzeitumgebung (z.B. Node.js, Python)
- Anwendungscode
- Dependencies
- Konfiguration

**Analogie:** Image = Klasse, Container = Instanz (aus Zyklus 01)

---

## Image-Lifecycle

```
Dockerfile → docker build → Image → docker run → Container
     ↓                         ↓
   Bauplan              Fertige Vorlage
```

**Wichtig:** Ein Image kann **viele Container** erzeugen!

---

## Images auflisten & inspizieren

### docker images - Alle lokalen Images anzeigen

```bash
docker images
```

**Output:**
```
REPOSITORY    TAG        IMAGE ID       CREATED        SIZE
nginx         latest     a1b2c3d4e5f6   2 days ago     142MB
node          18         b2c3d4e5f6a7   1 week ago     910MB
myapp         v1.0       c3d4e5f6a7b8   1 hour ago     250MB
```

**Spalten:**
- **REPOSITORY:** Image-Name (z.B. nginx, node, myapp)
- **TAG:** Version (z.B. latest, 18, v1.0)
- **IMAGE ID:** Eindeutige Hash-ID
- **CREATED:** Wann wurde das Image gebaut?
- **SIZE:** Speicherplatz

---

### docker images -a - Alle Images inkl. Zwischen-Images

```bash
docker images -a
```

Zeigt auch **intermediate images** (Layer aus Multi-Stage Builds).

**Normalerweise nicht nötig** (nur für Debugging).

---

### docker history - Layer-History anzeigen

```bash
docker history nginx
```

**Output:**
```
IMAGE          CREATED BY                                      SIZE
a1b2c3d4e5f6   CMD ["nginx" "-g" "daemon off;"]                0B
<missing>      EXPOSE 80                                       0B
<missing>      COPY nginx.conf /etc/nginx/nginx.conf          2kB
<missing>      RUN apt-get update && apt-get install...       50MB
<missing>      FROM debian:11-slim                             80MB
```

**Wichtig:**
- Jede Zeile = ein Layer
- `SIZE` zeigt, wie viel dieser Layer zum Image beiträgt
- Nützlich zum Debuggen großer Images

**Mit vollständigen Commands:**
```bash
docker history --no-trunc nginx
```
→ Zeigt komplette Befehle (nicht abgeschnitten)

---

## Images bauen

### docker build - Image aus Dockerfile erstellen

**Grundsyntax:**
```bash
docker build -t <name>:<tag> <pfad-zum-context>
```

**Beispiele:**
```bash
# Im aktuellen Verzeichnis (. = Build-Context)
docker build -t myapp:latest .

# Spezifisches Dockerfile nutzen
docker build -t myapp:v2 -f Dockerfile.prod .

# Mit Build-Args
docker build --build-arg VERSION=1.0 -t myapp .

# Ohne Cache (komplett neu)
docker build --no-cache -t myapp .
```

---

### Build-Context verstehen

```bash
docker build -t myapp .
                      ↑
                Build-Context (Verzeichnis)
```

**Build-Context =** Alle Dateien, die Docker zum Build zur Verfügung stehen.

**Beispiel:**
```
my-project/
├── src/
├── package.json
├── Dockerfile
└── node_modules/     ← Wird mitgeschickt (langsam!)
```

```bash
docker build -t myapp .
# Sendet ALLES an Docker Daemon (inkl. node_modules)

# Besser: .dockerignore erstellen
echo "node_modules" > .dockerignore
docker build -t myapp .
# Jetzt ohne node_modules → viel schneller!
```

---

## Images löschen

### docker rmi - Ein Image entfernen

```bash
docker rmi <image>
```

**Beispiele:**
```bash
# Nach Name:Tag
docker rmi nginx:1.25

# Nach Image-ID
docker rmi a1b2c3d4e5f6

# Force-Delete (auch wenn Container existieren)
docker rmi -f myapp:latest
```

**Warnung:** `-f` kann laufende Container brechen!

---

### docker image prune - Ungenutzte Images löschen

```bash
# Nur "dangling" Images (ohne Tag)
docker image prune

# Alle ungenutzten Images (nicht von Container genutzt)
docker image prune -a

# Ohne Bestätigung
docker image prune -a -f
```

**"Dangling" Images =** Images ohne Tag/Name:
```
<none>    <none>    c3d4e5f6a7b8   1 hour ago   250MB
```

Entstehen z.B. bei Rebuilds mit gleichem Tag.

---

## Images taggen & umbenennen

### docker tag - Image neu taggen

```bash
docker tag <alte-ref> <neue-ref>
```

**Beispiele:**
```bash
# Version-Tag hinzufügen
docker tag myapp:latest myapp:v1.0

# Für Registry vorbereiten
docker tag myapp:latest docker.io/username/myapp:v1.0

# Lokales Image umbenennen
docker tag old-name:latest new-name:latest
```

**Wichtig:** Erstellt **kein neues Image**, nur einen zweiten Namen für dasselbe Image!

---

## Images teilen

### docker save / docker load - Images als Datei exportieren/importieren

**Exportieren:**
```bash
docker save -o myapp.tar myapp:latest
```

**Importieren:**
```bash
docker load -i myapp.tar
```

**Anwendungsfall:** 
- Images ohne Registry teilen (z.B. USB-Stick)
- Offline-Deployments

---

### docker push / docker pull - Images mit Registry teilen

**Images von Docker Hub holen:**
```bash
docker pull nginx:1.25
docker pull python:3.11-slim
```

**Eigenes Image hochladen:**
```bash
# 1. Bei Docker Hub anmelden
docker login

# 2. Image taggen für Registry
docker tag myapp:latest username/myapp:v1.0

# 3. Pushen
docker push username/myapp:v1.0
```

---

## Image-Größe optimieren

### Strategie 1: Alpine-Images nutzen

```bash
# Vergleich:
docker pull node:18              # 910 MB
docker pull node:18-alpine       # 150 MB
```

**Vorteil:** ~85% kleiner  
**Nachteil:** Manche native Modules können Probleme haben (musl vs glibc)

---

### Strategie 2: Multi-Stage Builds

**Vorher (Single-Stage):**
```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install        # Inkl. Dev-Dependencies
COPY . .
RUN npm run build
CMD ["node", "dist/app.js"]
```
→ Image: ~950 MB (mit Dev-Dependencies!)

**Nachher (Multi-Stage):**
```dockerfile
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/app.js"]
```
→ Image: ~180 MB (nur Runtime!)

**Ersparnis:** ~80%

---

### Strategie 3: Layer-Anzahl reduzieren

```dockerfile
# ❌ Viele Layer
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get clean

# ✅ Ein Layer
RUN apt-get update && \
    apt-get install -y git curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

**Weniger Layer = kleineres Image**

---

### Strategie 4: .dockerignore nutzen

```
# .dockerignore
node_modules/
.git/
*.md
.env
npm-debug.log
```

**Verhindert:**
- Unnötige Dateien im Image
- Langsamer Build (weniger Daten zu übertragen)

---

## Speicherplatz verwalten

### docker system df - Speichernutzung anzeigen

```bash
docker system df
```

**Output:**
```
TYPE            TOTAL   ACTIVE   SIZE      RECLAIMABLE
Images          10      5        2.5GB     1.2GB (48%)
Containers      8       2        500MB     450MB (90%)
Local Volumes   3       1        1GB       800MB (80%)
Build Cache     -       -        3GB       2.5GB (83%)
```

**Was bedeutet das:**
- **RECLAIMABLE:** Kann sicher gelöscht werden (nicht in Benutzung)

---

### docker system prune - Alles Ungenutzte löschen

```bash
# Gestoppte Container + dangling Images + ungenutzte Networks
docker system prune

# + Alle ungenutzten Images
docker system prune -a

# + Volumes
docker system prune -a --volumes

# Ohne Bestätigung
docker system prune -a -f
```

**Vorsicht:** `--volumes` löscht auch Daten!

---

## Häufige Probleme & Lösungen

### Problem 1: "No space left on device"

**Ursache:** Docker Images/Container füllen Festplatte.

**Lösung:**
```bash
# Speichernutzung prüfen
docker system df

# Aufräumen
docker system prune -a
docker volume prune
```

---

### Problem 2: Image-Tag "latest" ist veraltet

**Problem:**
```bash
docker pull myapp        # Holt myapp:latest
# Aber 'latest' ist alt - neue Version ist v2.0
```

**Lösung:** Immer **spezifische Tags** nutzen:
```bash
docker pull myapp:v2.0   # Explizite Version
```

---

### Problem 3: Kann Image nicht löschen - "container still using it"

**Ursache:** Container (auch gestoppte) nutzen das Image noch.

**Lösung:**
```bash
# Container finden
docker ps -a --filter ancestor=myapp

# Container löschen
docker rm <container-id>

# Dann Image löschen
docker rmi myapp
```

**Oder Force-Delete (gefährlich):**
```bash
docker rmi -f myapp
```

---

### Problem 4: Build dauert ewig

**Ursachen:**
1. Kein Layer-Caching (alles neu gebaut)
2. Riesiger Build-Context (z.B. node_modules mitgeschickt)
3. Langsame Dependencies-Installation

**Lösungen:**
```bash
# 1. Cache prüfen
docker build -t myapp .   # Zweiter Build sollte schneller sein

# 2. .dockerignore erstellen
echo "node_modules" >> .dockerignore
echo ".git" >> .dockerignore

# 3. Dependencies cachen (Dockerfile optimieren)
# COPY package.json VOR COPY . .
```

---

## Best Practices

### 1. Immer spezifische Tags

```bash
# ❌ Vermeiden
FROM node:latest
docker pull nginx

# ✅ Besser
FROM node:18.16.0
docker pull nginx:1.25
```

**Grund:** `latest` kann sich ändern → Builds nicht reproduzierbar

---

### 2. Images regelmäßig aktualisieren

```bash
# Base-Images regelmäßig neu pullen
docker pull node:18
docker pull nginx:1.25

# Dann Rebuild
docker build --no-cache -t myapp .
```

**Grund:** Security-Updates in Base-Images

---

### 3. Ungenutzte Images löschen

```bash
# Wöchentlich aufräumen
docker image prune -a
```

**Spart:** Speicherplatz + schnellere `docker images` Liste

---

### 4. Image-Namen mit Versionierung

```bash
# ✅ Gut
myapp:v1.0.0
myapp:v1.0.1
myapp:v2.0.0

# ❌ Schlecht
myapp:latest    # Welche Version ist das?
myapp:new
myapp:final     # Famous last words
```

---

## Kommando-Übersicht

```bash
# Images auflisten
docker images
docker images -a                # Inkl. Zwischen-Images

# Image bauen
docker build -t name:tag .
docker build --no-cache -t name:tag .

# Image-Details
docker history <image>
docker history --no-trunc <image>
docker inspect <image>

# Image taggen
docker tag old-name:tag new-name:tag

# Images löschen
docker rmi <image>
docker rmi -f <image>
docker image prune              # Dangling Images
docker image prune -a           # Alle ungenutzten

# Images teilen
docker save -o file.tar <image>
docker load -i file.tar
docker push <image>
docker pull <image>

# Speicher verwalten
docker system df
docker system prune -a
```

---

## Zusammenfassung

**Die 5 wichtigsten Regeln:**

1. **Spezifische Tags:** Niemals `latest` in Production
2. **Regelmäßig aufräumen:** `docker image prune -a`
3. **Layer-Caching nutzen:** Dependencies vor Code
4. **Multi-Stage Builds:** Für kleine Production-Images
5. **Security:** Base-Images regelmäßig aktualisieren

**Nächster Schritt:** Praktische Aufgaben mit Image-Management
