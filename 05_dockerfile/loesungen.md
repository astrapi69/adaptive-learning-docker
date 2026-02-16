# Lösungen: Dockerfile Best Practices

## Aufgabe 1: Layer-Caching verstehen

**1. Was passiert beim zweiten Build nach Code-Änderung?**

Alle Layer ab `COPY . .` werden **neu gebaut**:
```
FROM node:18          ✅ Cached
WORKDIR /app          ✅ Cached
COPY . .              ❌ Invalidiert (app.js geändert)
RUN npm install       ❌ Neu gebaut (Layer darunter invalidiert)
CMD [...]             ❌ Neu gebaut
```

**2. Warum problematisch?**

`npm install` läuft komplett neu, obwohl `package.json` **nicht** geändert wurde.
→ Verschwendet Minuten bei jedem Build!

**3. Optimierte Version:**

```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./       # Dependencies-Dateien zuerst
RUN npm install             # Wird nur bei package.json-Änderung neu gebaut
COPY . .                    # Code danach
CMD ["node", "app.js"]
```

**Ergebnis:** Code-Änderungen nutzen gecachte Dependencies ✅

---

## Aufgabe 2: Cache-Optimierung

**Optimale Reihenfolge:**

```dockerfile
FROM node:18                # 1. Base-Image (ändert sich nie)
WORKDIR /app                # 2. Config (selten geändert)
COPY package*.json ./       # 3. Dependencies-Dateien (manchmal)
RUN npm install             # 4. Install (cached wenn 3. gleich)
COPY . .                    # 5. Code (oft geändert)
CMD ["node", "app.js"]      # 6. Runtime-Befehl
```

**Warum optimal?**

Anweisungen sind von **selten** zu **oft** geändert sortiert:
- Jede Änderung invalidiert nur Layer **darunter**
- Layers darüber bleiben gecached
- Code-Änderungen (häufig) → nur `COPY . .` neu gebaut
- Dependencies (selten) → `npm install` bleibt gecached

---

## Aufgabe 3: Port-Mapping & Dockerfile

**1. Container auf Host-Port 8080 starten:**
```bash
docker build -t my-nginx .
docker run -p 8080:80 my-nginx
```

**2. nginx läuft auf Port 80 im Container** (nginx default)

**3. Warum kein EXPOSE im Dockerfile?**

`EXPOSE` ist nur **Dokumentation**, ändert nichts am Runtime-Verhalten.
Port-Mapping erfolgt mit `-p` beim `docker run`.

**Optional könnte man hinzufügen:**
```dockerfile
FROM nginx:1.25
COPY index.html /usr/share/nginx/html/
EXPOSE 80          # Dokumentiert, dass Port 80 genutzt wird
```

---

## Aufgabe 4: Secrets-Problem erkennen

**1. Warum NICHT sicher?**

Jeder Layer ist **unveränderlich** und bleibt in der Image-History:
```dockerfile
COPY .env /app/.env         # ← Layer mit Secret erstellt
...
RUN rm /app/.env            # ← Neuer Layer (löscht nur im aktuellen)
```

Der Secret-Layer bleibt im Image!

**2. Wie auslesen?**

```bash
docker history --no-trunc myapp
# Zeigt alle Layer mit vollständigen Commands
# .env-Inhalt ist dort sichtbar
```

Oder Image entpacken und Layer durchsuchen.

**3. Richtige Methode:**

```bash
# Zur Runtime übergeben (NICHT im Dockerfile)
docker run -e API_KEY=secret myapp

# Oder in docker-compose.yml
services:
  app:
    image: myapp
    environment:
      - API_KEY=secret
```

**Regel:** Secrets gehören NIEMALS ins Image, auch nicht temporär!

---

## Aufgabe 5: Multi-Stage Build

**Lösung:**

```dockerfile
# Stage 1: Build
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build           # Erzeugt /app/build/

# Stage 2: Production
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Was passiert:**
1. Stage 1: Komplett Build (inkl. Dev-Dependencies) → ~800MB
2. Stage 2: Nur die Build-Files kopiert → ~25MB
3. **Finales Image: 25MB** (nur Stage 2 wird behalten)

**Vorteil:** 97% kleiner, ohne Build-Tools in Production!

---

## Aufgabe 6: .dockerignore nutzen

**1. Was wird kopiert?**

ALLES:
- `node_modules/` (300 MB - unnötig!)
- `.git/` (50 MB - unnötig!)
- `README.md` (unnötig)
- Dockerfile selbst (unnötig)
- src/, package.json ✅ (brauchen wir)

**2. .dockerignore Inhalt:**

```
node_modules/
.git/
*.md
.env
.DS_Store
npm-debug.log
Dockerfile
.dockerignore
```

**3. Warum ist node_modules problematisch?**

- 300 MB werden unnötig ins Image kopiert
- Wird dann von `npm install` neu überschrieben
- Verschwendet Build-Zeit
- Macht Image riesig

**Optimiert mit .dockerignore:**
```dockerfile
COPY . .        # Jetzt ohne node_modules, .git, etc.
```
→ Nur ~5 MB statt 350 MB kopiert!

---

## Aufgabe 7: WORKDIR verstehen

**Variante B ist deutlich besser!**

**Unterschiede:**

| Aspekt | Variante A | Variante B |
|--------|------------|------------|
| Lesbarkeit | `cd` überall wiederholt | Klar, WORKDIR einmal gesetzt |
| Fehleranfälligkeit | Hoch (cd vergessen?) | Niedrig |
| CMD-Syntax | Shell-Form (weniger robust) | Exec-Form (bevorzugt) |
| Pfade | Absolut (`/app/...`) | Relativ (`.`) |

**Was macht WORKDIR:**
- Setzt Arbeitsverzeichnis für **alle** folgenden Anweisungen
- `COPY`, `RUN`, `CMD` nutzen automatisch diesen Pfad
- Erstellt Verzeichnis, falls nicht vorhanden

**Best Practice:** Immer `WORKDIR` nutzen, nicht `cd`!

---

## Aufgabe 8: Image-Build debuggen

**1. Mögliche Probleme:**

- `package.json` wurde nicht ins Image kopiert
- `.dockerignore` blockiert `package.json`
- `COPY` vor `WORKDIR` → falsche Location

**2. Dateien im Image prüfen:**

```bash
# Image bauen (auch wenn fehlerhaft)
docker build -t myapp .

# In gestopptem Build-Container schauen
docker run --rm -it myapp ls /app

# Oder interaktiv troubleshooten
docker run --rm -it myapp sh
ls -la
cat package.json
```

**3. Layer-History anzeigen:**

```bash
docker history myapp
# Zeigt alle Layer mit Commands

docker history --no-trunc myapp
# Zeigt vollständige Commands (nicht gekürzt)
```

**Wahrscheinlichste Lösung:**
```dockerfile
# Problem
COPY package.json ./        # 'express' fehlt in package.json

# Oder
COPY . .                    # package.json in .dockerignore
```

---

## Aufgabe 9: Security - Non-Root User

**Lösung:**

```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Eigentümer auf 'node' User setzen
RUN chown -R node:node /app

# Ab hier als non-root User
USER node

CMD ["node", "app.js"]
```

**Wichtig:**
- `chown` **vor** `USER` (root-Rechte nötig)
- `USER node` wechselt zu unprivilegiertem User
- Alle folgenden Commands (inkl. `CMD`) laufen als `node`

**Prüfen:**
```bash
docker run --rm myapp whoami
# Output: node ✅ (nicht root)
```

---

## Aufgabe 10: Cache invalidieren

**1. Was ist passiert?**

Docker nutzt den **gecachten Layer** von `npm install`, obwohl `package.json` sich geändert hat.

**Mögliche Ursachen:**
- Timestamp von `package.json` nicht geändert (nur Inhalt)
- Docker vergleicht Datei-Hashes, aber manchmal gibt's Edge-Cases

**2. Build ohne Cache:**

```bash
docker build --no-cache -t myapp .
```

**Alternative (nur ab einem bestimmten Layer):**
```bash
# Temporäre Datei ändern, um Cache zu brechen
touch package.json
docker build -t myapp .
```

**3. Wann ohne Cache bauen?**

- Nach `package.json` Änderungen, die nicht erkannt werden
- Debugging von Cache-Problemen
- Production-Builds (sicherstellen, dass alles frisch ist)

**Warnung:** Dauert deutlich länger (kein Caching)

---

## Bonus-Aufgabe: Flask Dockerfile

**Lösung:**

```dockerfile
FROM python:3.11-slim

# Arbeitsverzeichnis setzen
WORKDIR /app

# Dependencies zuerst (für Caching)
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Code kopieren
COPY . .

# Non-root User erstellen und nutzen
RUN useradd -m -u 1000 flaskuser && \
    chown -R flaskuser:flaskuser /app
USER flaskuser

# Port dokumentieren
EXPOSE 5000

# App starten
CMD ["python", "app.py"]
```

**Best Practices angewendet:**

1. ✅ Cache-Optimierung (requirements.txt vor Code)
2. ✅ Non-root User (flaskuser)
3. ✅ `--no-cache-dir` bei pip (kleineres Image)
4. ✅ Slim-Image (kleiner als full python)
5. ✅ EXPOSE für Dokumentation
6. ✅ Exec-Form bei CMD

**Optional mit Multi-Stage (falls Build nötig):**

```dockerfile
# Stage 1: Dependencies installieren
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
RUN useradd -m -u 1000 flaskuser && \
    chown -R flaskuser:flaskuser /app
USER flaskuser
ENV PATH=/root/.local/bin:$PATH
EXPOSE 5000
CMD ["python", "app.py"]
```

---

## Zusammenfassung der Lernziele

Nach diesen Aufgaben solltest du verstehen:

✅ Layer-Caching & Optimierung  
✅ Dockerfile-Anweisungen (FROM, WORKDIR, COPY, RUN, CMD)  
✅ .dockerignore nutzen  
✅ Secrets NIEMALS im Dockerfile  
✅ Multi-Stage Builds für kleinere Images  
✅ Non-root User für Security  
✅ Cache-Invalidierung & Troubleshooting  

**Nächster Schritt:** Zyklus 06 - Image Management
