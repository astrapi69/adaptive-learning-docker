# Lösungen: Image Management

## Aufgabe 1: Images vs Container unterscheiden

**1. Stimmt die Aussage?**

Nein! 5 Container ≠ 5 Images.

**2. Wie viele Images?**

Wahrscheinlich **1 Image** (`nginx`), daraus wurden 5 Container erstellt.

**Analogie:** 1 Klasse (Image) → 5 Objekte (Container)

**3. Befehle:**
```bash
docker ps          # Container anzeigen
docker images      # Images anzeigen
```

---

## Aufgabe 2: Image-Liste interpretieren

**1. Warum gleiche IMAGE ID?**

```
nginx    latest   a1b2c3d4e5f6
nginx    1.25     a1b2c3d4e5f6   # ← Gleiche ID!
```

Das sind **zwei Tags für dasselbe Image**.  
`nginx:latest` zeigt auf `nginx:1.25`.

**Vergleich:**
```bash
docker tag nginx:1.25 nginx:latest
# Erstellt zweiten Tag, kein neues Image
```

**2. Was ist `<none>`?**

Ein **"dangling" Image** - Image ohne Tag/Namen.

**Ursachen:**
- Rebuild mit gleichem Tag → altes Image verliert Namen
- Fehlgeschlagener Build
- Intermediate Image aus Multi-Stage

**Löschen:**
```bash
docker image prune   # Entfernt alle <none> Images
```

**3. Speicherplatz gesamt?**

**Trick:** Nicht einfach addieren!

```
nginx:latest   142MB  ← \
nginx:1.25     142MB  ←  } Gleiches Image = 142MB (nicht 284MB!)
myapp:v1.0     250MB
<none>         180MB
---
GESAMT: 572MB (nicht 714MB!)
```

**Regel:** Images mit gleicher ID zählen nur 1x!

---

## Aufgabe 3: Image bauen & taggen

**1. Image bauen:**
```bash
cd ~/myproject/
docker build -t myapp:v1.0 .
```

**2. Zweiten Tag hinzufügen:**
```bash
docker tag myapp:v1.0 myapp:latest
```

**3. Zeigen, dass beide gleich sind:**
```bash
docker images | grep myapp
```

**Output:**
```
myapp    v1.0     c3d4e5f6a7b8   ...   250MB
myapp    latest   c3d4e5f6a7b8   ...   250MB
         ↑
  Gleiche IMAGE ID = gleiches Image!
```

---

## Aufgabe 4: Image-History analysieren

**1. Layer-Größen anzeigen:**
```bash
docker history myapp:v1.0
```

**2. Befehl für großen Layer finden:**
```bash
docker history --no-trunc myapp:v1.0
```

**Output (Beispiel):**
```
IMAGE     CREATED BY                           SIZE
...
c3d4...   RUN apt-get install build-tools     1.5GB   ← Problem!
```

**3. Optimierung:**

**Problem gefunden:** `build-tools` wird installiert, aber nicht gebraucht zur Runtime.

**Lösung - Multi-Stage Build:**
```dockerfile
# Stage 1: Build (mit build-tools)
FROM ubuntu:22.04 AS builder
RUN apt-get update && apt-get install -y build-tools
COPY . /app
RUN make build

# Stage 2: Runtime (ohne build-tools)
FROM ubuntu:22.04
COPY --from=builder /app/binary /app/
CMD ["/app/binary"]
```

**Ergebnis:** Von 2GB auf 500MB reduziert!

---

## Aufgabe 5: Aufräumen

**1. Was bedeutet "RECLAIMABLE 12GB (80%)"?**

- **12GB** können sicher gelöscht werden
- **80%** aller Images werden nicht genutzt (42 von 45 Images)
- **3 Images** werden aktiv von Containern genutzt

**2. Alle ungenutzten Images löschen:**
```bash
docker image prune -a
```

**Warnung:** Bestätigung erforderlich! (Mit `-f` überspringen)

**3. Unterschied `prune` vs `prune -a`:**

| Befehl | Löscht |
|--------|--------|
| `docker image prune` | Nur **dangling** Images (`<none>`) |
| `docker image prune -a` | **Alle** ungenutzten Images (auch getaggte) |

**Beispiel:**
```
<none>    <none>   ...    ← docker image prune
myapp     v1.0     ...    ← docker image prune -a (falls nicht genutzt)
```

---

## Aufgabe 6: Image löschen - Fehler

**1. Warum kann Image nicht gelöscht werden?**

Container `abc123` nutzt das Image noch (auch wenn gestoppt).

**Docker-Regel:** Images mit laufenden/gestoppten Containern können nicht gelöscht werden.

**2. Container finden:**
```bash
docker ps -a | grep abc123

# Oder spezifischer:
docker ps -a --filter id=abc123
```

**3. Image UND Container löschen:**

**Option A - Sauber:**
```bash
docker rm abc123         # Container löschen
docker rmi myapp:v1.0    # Image löschen
```

**Option B - Schnell:**
```bash
docker rm -f abc123      # Container force-löschen
docker rmi myapp:v1.0    # Image löschen
```

**Option C - Atomic:**
```bash
docker rmi -f myapp:v1.0   # Force-Delete (löscht trotz Container)
```

**Warnung:** Option C kann Container brechen → nur für Cleanup nutzen!

---

## Aufgabe 7: Build-Context

**1. Warum 702 MB?**

Docker schickt **ALLES** aus `my-project/` zum Daemon:
- `node_modules/` (500 MB)
- `.git/` (200 MB)
- `src/` (~2 MB)

**Regel:** Build-Context = gesamtes Verzeichnis (außer in .dockerignore)

**2. Auf ~5 MB reduzieren:**

Mit `.dockerignore` unnötige Dateien ausschließen.

**3. .dockerignore Datei:**

```
# .dockerignore
node_modules/
.git/
.gitignore
*.md
.env
.DS_Store
npm-debug.log
Dockerfile
.dockerignore
```

**Ergebnis:**
```bash
docker build -t myapp .
# Sending build context: 5MB   ✅
```

**Geschwindigkeit:** ~100x schneller beim Context-Transfer!

---

## Aufgabe 8: Image-Größe Alpine

**1. Welche Variante kleiner?**

**Variante B** (`node:18-alpine`) wird deutlich kleiner sein.

**2. Ungefähr wie viel?**

**Variante A:** ~910 MB  
**Variante B:** ~150 MB  

**Ersparnis:** ~**84%** kleiner!

**3. Nachteile Alpine?**

- **musl** statt **glibc** → manche native Node-Modules funktionieren nicht
- Fehlende Tools (bash, etc.) → Debugging schwieriger
- Manche Python-Packages brauchen zusätzliche Build-Dependencies

**Empfehlung:**
- **Production:** Alpine (klein, schnell, sicher)
- **Development:** Standard-Image (alle Tools vorhanden)

---

## Aufgabe 9: Images teilen ohne Registry

**1. Image exportieren:**
```bash
docker save -o myapp.tar myapp:v1.0
```

**Oder komprimiert:**
```bash
docker save myapp:v1.0 | gzip > myapp.tar.gz
```

**2. Auf Zielrechner importieren:**
```bash
docker load -i myapp.tar

# Oder mit Kompression:
gunzip < myapp.tar.gz | docker load
```

**3. Werden Tags mit exportiert?**

**Ja!** Tags und alle Layer werden mit exportiert.

**Prüfen:**
```bash
# Nach docker load
docker images | grep myapp
# Output: myapp   v1.0   ...
```

**Anwendungsfall:**
- Air-gapped Systeme (kein Internet)
- Offline-Deployments
- Image-Backup

---

## Aufgabe 10: Multi-Stage Build

**1. Welches größer?**

**Single-Stage:** ~950 MB  
**Multi-Stage:** ~180 MB

**Single-Stage ist 5x größer!**

**2. Nur im Single-Stage:**

- `package.json` (Original)
- `src/` Verzeichnis (Source-Code)
- Dev-Dependencies (`node_modules` mit `devDependencies`)
- Build-Tools

**Multi-Stage enthält nur:**
- `dist/` (kompilierter Code)
- Production `node_modules`

**3. Warum Multi-Stage besser?**

**Sicherheit:**
- Kein Source-Code im Image
- Keine Build-Tools (kleinere Angriffsfläche)

**Performance:**
- 5x kleineres Image → schnellerer Download
- Weniger Layer → schnellerer Container-Start

**Best Practice:**
- Production: **IMMER** Multi-Stage
- Development: Single-Stage OK (einfacher zu debuggen)

---

## Aufgabe 11: Image-Updates

**1. Automatisch neue Version?**

**Nein!** Lokales Image wird **nicht** automatisch aktualisiert.

```bash
docker run nginx:1.24    # Nutzt LOKALES Image (alt)
```

**2. Neue Version holen:**
```bash
docker pull nginx:1.24   # Lädt neueste Version von Registry
```

**3. Builds aktuell halten:**

```dockerfile
FROM nginx:1.24
```

```bash
# Vor dem Build:
docker pull nginx:1.24
docker build -t myapp .

# Oder Force-Pull beim Build:
docker build --pull -t myapp .
```

`--pull` holt Base-Image neu vom Registry.

**Best Practice:**
- **CI/CD:** Immer `--pull` nutzen
- **Lokal:** Regelmäßig `docker pull` für Base-Images

---

## Aufgabe 12: "latest" verstehen

**1. Warum unterschiedliche Versionen?**

**Lokal:** `python:latest` zeigt auf Python 3.11 (Bild gecached)  
**CI/CD:** `python:latest` zeigt auf Python 3.12 (neues `latest` gepullt)

**Problem:** `latest` ist **kein fixer Tag** - er bewegt sich!

**2. Fix:**
```dockerfile
FROM python:3.11        # Spezifische Version
```

**Noch besser:**
```dockerfile
FROM python:3.11.6      # Exakte Version
```

**3. Warum `latest` vermeiden?**

**Probleme:**
- ❌ Nicht reproduzierbar (Build heute ≠ Build morgen)
- ❌ Breaking Changes möglich
- ❌ Debugging schwierig ("welche Version lief da?")

**Regel:** `latest` nur für Experimente, **nie** in Production!

---

## Bonus-Aufgabe: Image-Optimierung

**Aktuell: 850 MB**

**Problem-Analyse:**
1. `ubuntu:22.04` ist groß (~80 MB Base)
2. Jedes `RUN` = eigener Layer
3. Kein Cleanup nach `apt-get`
4. Python aus APT (bläht auf)

**Optimierte Version (unter 200 MB):**

```dockerfile
# Slim Base-Image
FROM python:3.11-slim

# Kombinierte Installation + Cleanup
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Dependencies cachen
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Code kopieren
COPY . .

CMD ["python3", "app.py"]
```

**Ergebnis:** ~120 MB ✅

**Optimierungen:**
1. ✅ `python:3.11-slim` statt `ubuntu` (-400 MB)
2. ✅ Kombinierte RUN-Befehle (-50 MB extra Layer)
3. ✅ `apt-get clean` + `rm -rf /var/lib/apt/lists/*` (-200 MB)
4. ✅ `--no-install-recommends` (-100 MB unnötige Packages)
5. ✅ `pip --no-cache-dir` (-50 MB pip cache)

**Von 850 MB auf 120 MB = 86% Reduktion!**

---

## Zusammenfassung

Nach diesen Aufgaben verstehst du:

✅ Images vs. Container  
✅ Image-Tags & IDs  
✅ Build-Context & .dockerignore  
✅ Image-History analysieren  
✅ Images aufräumen & Speicher verwalten  
✅ Alpine vs. Standard Images  
✅ Multi-Stage Builds  
✅ "latest" Tag vermeiden  
✅ Image-Optimierung (5-10x kleiner)

**Nächster Schritt:** Anwendung in echten Projekten!
