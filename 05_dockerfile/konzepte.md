# Dockerfile Best Practices

## Was ist ein Dockerfile?

Ein **Dockerfile** ist eine Textdatei mit Anweisungen, wie ein Docker-Image gebaut werden soll. Jede Anweisung erzeugt einen **Layer** im finalen Image.

**Grundstruktur:**
```dockerfile
FROM node:18              # Base-Image
WORKDIR /app              # Arbeitsverzeichnis setzen
COPY package*.json ./     # Dependencies-Dateien kopieren
RUN npm install           # Dependencies installieren
COPY . .                  # Code kopieren
CMD ["node", "app.js"]    # Start-Befehl
```

---

## Layer-Caching: Das wichtigste Konzept

### Wie funktioniert Layer-Caching?

Jede Dockerfile-Anweisung (`FROM`, `COPY`, `RUN`, `CMD`) erzeugt einen **Layer**:
- Docker cached jeden Layer
- Cache wird invalidiert, wenn sich Input ändert
- **Alle darunterliegenden Layer werden neu gebaut**

**Beispiel - Schlechtes Caching:**
```dockerfile
FROM node:18
WORKDIR /app
COPY . .                    # ← Code ändert sich ständig
RUN npm install             # ← Wird IMMER neu gebaut (langsam!)
CMD ["node", "app.js"]
```

**Problem:** Jede Code-Änderung → `npm install` läuft komplett neu (Minuten verschwendet)

---

**Beispiel - Optimiertes Caching:**
```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./       # ← Ändert sich selten
RUN npm install             # ← Wird gecached, solange package.json gleich
COPY . .                    # ← Code-Änderungen invalidieren nur diesen Layer
CMD ["node", "app.js"]
```

**Ergebnis:** Code-Änderungen nutzen gecachte Dependencies → Sekunden statt Minuten!

---

## Wichtige Dockerfile-Anweisungen

### FROM - Base-Image wählen
```dockerfile
FROM node:18              # Spezifische Version (IMMER taggen!)
FROM node:18-alpine       # Alpine = kleineres Image (Produktion)
FROM ubuntu:22.04         # OS-Image
```

**Regel:** NIEMALS `latest` verwenden → Reproduzierbarkeit!

---

### WORKDIR - Arbeitsverzeichnis setzen
```dockerfile
# ❌ Schlecht
FROM node:18
COPY . /app
RUN cd /app && npm install    # cd in jedem RUN wiederholen

# ✅ Gut
FROM node:18
WORKDIR /app                  # Einmal setzen
COPY . .                      # Relativ zu /app
RUN npm install               # Automatisch in /app
```

**Vorteil:** Alle Befehle laufen im gleichen Verzeichnis

---

### COPY - Dateien ins Image kopieren
```dockerfile
COPY package.json ./          # Einzelne Datei
COPY package*.json ./         # Wildcard (package.json + package-lock.json)
COPY . .                      # Alles (nutze .dockerignore!)
COPY src/ ./src/              # Verzeichnis
```

**Cache-Optimierung:** Dependencies zuerst, dann Code!

---

### RUN - Befehle während Build ausführen
```dockerfile
RUN npm install               # Dependencies installieren
RUN apt-get update && \       # Mehrere Befehle kombinieren
    apt-get install -y git
RUN npm run build             # Build-Schritt
```

**Regel:** Kombiniere zusammengehörige Befehle in einem RUN (weniger Layer)

---

### CMD - Start-Befehl (Container-Runtime)
```dockerfile
CMD ["node", "app.js"]        # Exec-Form (bevorzugt)
CMD node app.js               # Shell-Form (nutzt /bin/sh)
```

**Unterschied zu RUN:** 
- `RUN` läuft während Image-Build
- `CMD` läuft beim Container-Start

---

### ENV - Umgebungsvariablen
```dockerfile
ENV NODE_ENV=production
ENV PORT=3000
```

**Warnung:** NIEMALS Secrets hier! (Bleiben im Image sichtbar)

---

## .dockerignore - Unnötige Dateien ausschließen

**Beispiel `.dockerignore`:**
```
node_modules/
npm-debug.log
.git/
.env
.DS_Store
*.md
Dockerfile
```

**Warum wichtig:**
- Schnellerer Build (weniger Daten zu kopieren)
- Kleineres Image
- Verhindert, dass Secrets ins Image kommen

---

## Multi-Stage Builds (Advanced)

**Problem:** Build-Tools (Compiler, Dev-Dependencies) brauchen wir nur beim Build, nicht zur Runtime.

**Lösung - Multi-Stage:**
```dockerfile
# Stage 1: Build
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install           # Inkl. Dev-Dependencies
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:18-alpine       # Kleineres Base-Image
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/app.js"]
```

**Ergebnis:** 
- Stage 1: ~800MB (mit Build-Tools)
- Stage 2: ~150MB (nur Runtime)
- **Finales Image: 150MB** ✅

---

## Security Best Practices

### 1. Keine Secrets im Dockerfile
```dockerfile
# ❌ NIEMALS!
ENV API_KEY=super-secret-123

# ❌ Auch das hilft NICHT!
COPY .env /app/.env
RUN rm /app/.env              # Layer bleibt trotzdem sichtbar!
```

**Warum problematisch:** Jeder Layer ist unveränderlich und mit `docker history` auslesbar.

**Richtig:** Secrets zur Runtime übergeben
```bash
docker run -e API_KEY=secret app
```

---

### 2. Non-Root User
```dockerfile
# ❌ Läuft als root (Sicherheitsrisiko)
FROM node:18
WORKDIR /app
COPY . .
CMD ["node", "app.js"]

# ✅ Läuft als unprivilegierter User
FROM node:18
WORKDIR /app
COPY . .
RUN chown -R node:node /app
USER node                    # Ab hier als 'node' User
CMD ["node", "app.js"]
```

---

### 3. Spezifische Image-Tags
```dockerfile
# ❌ Vermeiden
FROM node:latest             # Kann sich ändern!

# ✅ Besser
FROM node:18.16.0            # Fixierte Version
FROM node:18.16.0-alpine     # + kleineres Image
```

---

## Optimierungsstrategien

### 1. Layer-Anzahl reduzieren
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

---

### 2. Cache-freundliche Reihenfolge
```dockerfile
# Von selten zu oft geändert:
FROM node:18                 # 1. Base (fast nie)
WORKDIR /app                 # 2. Config (selten)
COPY package*.json ./        # 3. Dependencies (manchmal)
RUN npm install              # 4. Install (cached wenn 3. gleich)
COPY . .                     # 5. Code (ständig)
RUN npm run build            # 6. Build (bei Code-Änderung)
CMD ["node", "dist/app.js"]  # 7. Runtime
```

---

### 3. Alpine-Images nutzen
```dockerfile
FROM node:18              # ~900MB
FROM node:18-alpine       # ~150MB (gleiche Funktionalität)
```

**Vorsicht:** Alpine nutzt `musl` statt `glibc` → manche native Modules können Probleme haben

---

## Häufige Fehler

### Fehler 1: Code vor Dependencies kopieren
```dockerfile
# ❌ Schlecht
COPY . .
RUN npm install             # Bei jeder Code-Änderung neu

# ✅ Gut
COPY package*.json ./
RUN npm install             # Cached, solange package.json gleich
COPY . .
```

---

### Fehler 2: Fehlende .dockerignore
```dockerfile
COPY . .                    # Kopiert ALLES (inkl. node_modules, .git)
```
→ Riesiges Image, langsamer Build

**Lösung:** `.dockerignore` mit node_modules, .git, etc.

---

### Fehler 3: Root-User in Production
```dockerfile
CMD ["node", "app.js"]      # Läuft als root
```
→ Sicherheitsrisiko

**Lösung:** `USER node` vor CMD

---

## Zusammenfassung

**Die 5 wichtigsten Regeln:**

1. **Cache-Optimierung:** Dependencies vor Code kopieren
2. **Spezifische Tags:** Niemals `latest`
3. **Keine Secrets:** Niemals im Dockerfile, auch nicht temporär
4. **Multi-Stage Builds:** Für kleinere Production-Images
5. **Non-Root User:** Sicherheit in Production

**Merkregel für Reihenfolge:**
> "Von **selten** zu **oft** geändert"

---

## Weiterführende Themen

- Health Checks (`HEALTHCHECK`)
- Build Args (`ARG`)
- Entry Points (`ENTRYPOINT` vs `CMD`)
- Docker Compose mit custom Dockerfiles
- BuildKit Features (neue Build-Engine)
