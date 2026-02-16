# Aufgaben: Image Management

## Aufgabe 1: Images vs Container unterscheiden

Ein Kollege sagt: "Ich hab 5 nginx-Container laufen, also hab ich 5 nginx-Images."

**Fragen:**
1. Stimmt diese Aussage?
2. Wie viele nginx-Images hat der Kollege wahrscheinlich?
3. Welcher Befehl zeigt dir Container, welcher zeigt Images?

---

## Aufgabe 2: Image-Liste interpretieren

Du führst `docker images` aus und siehst:

```
REPOSITORY    TAG        IMAGE ID       CREATED        SIZE
nginx         latest     a1b2c3d4e5f6   2 days ago     142MB
nginx         1.25       a1b2c3d4e5f6   2 days ago     142MB
myapp         v1.0       c3d4e5f6a7b8   1 hour ago     250MB
<none>        <none>     d4e5f6a7b8c9   3 hours ago    180MB
```

**Fragen:**
1. Warum haben `nginx:latest` und `nginx:1.25` die **gleiche** IMAGE ID?
2. Was ist das `<none>` Image?
3. Wie viel Speicherplatz nutzen alle Images **zusammen**? (Trick-Frage!)

---

## Aufgabe 3: Image bauen & taggen

Du hast ein Dockerfile im Verzeichnis `~/myproject/`.

**Aufgaben:**
1. Baue ein Image mit Namen `myapp` und Tag `v1.0`
2. Füge einen zweiten Tag `latest` für dasselbe Image hinzu
3. Zeige, dass beide Tags zum gleichen Image gehören

**Welche Befehle nutzt du?**

---

## Aufgabe 4: Image-History analysieren

Ein Image ist unerwartet groß (2 GB). Du willst herausfinden, warum.

**Aufgaben:**
1. Welcher Befehl zeigt die Layer-Größen des Images?
2. Du siehst einen Layer mit 1.5 GB - wie findest du heraus, welcher Befehl ihn erzeugt hat?
3. Wie würdest du das Image optimieren?

---

## Aufgabe 5: Aufräumen - Ungenutzte Images

Nach wochenlangem Entwickeln ist deine Festplatte voll.

```bash
docker system df
```

```
TYPE      TOTAL   ACTIVE   SIZE      RECLAIMABLE
Images    45      3        15GB      12GB (80%)
```

**Aufgaben:**
1. Was bedeutet "RECLAIMABLE 12GB (80%)"?
2. Welcher Befehl löscht **alle** ungenutzten Images?
3. Was ist der Unterschied zwischen `docker image prune` und `docker image prune -a`?

---

## Aufgabe 6: Image löschen - Fehler beheben

Du versuchst, ein Image zu löschen:

```bash
docker rmi myapp:v1.0
```

**Fehler:**
```
Error: conflict: unable to remove repository reference "myapp:v1.0" 
(must force) - container abc123 is using its referenced image
```

**Aufgaben:**
1. Warum kann das Image nicht gelöscht werden?
2. Wie findest du den Container `abc123`?
3. Wie löschst du Image UND Container?

---

## Aufgabe 7: Build-Context verstehen

Deine Projekt-Struktur:

```
my-project/
├── node_modules/    # 500 MB
├── .git/            # 200 MB
├── src/
│   └── app.js
├── package.json
└── Dockerfile
```

Du führst aus:
```bash
docker build -t myapp .
```

**Ausgabe:**
```
Sending build context to Docker daemon  702MB
```

**Fragen:**
1. Warum werden 702 MB übertragen?
2. Wie reduzierst du das auf ~5 MB?
3. Erstelle eine passende `.dockerignore` Datei.

---

## Aufgabe 8: Image-Größe vergleichen

Du baust dasselbe Image mit verschiedenen Base-Images:

**Variante A:**
```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
```

**Variante B:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install
```

**Aufgaben:**
1. Welche Variante wird wahrscheinlich kleiner sein?
2. Ungefähr wie viel kleiner? (Prozent)
3. Gibt es Nachteile bei Alpine-Images?

---

## Aufgabe 9: Images teilen (ohne Registry)

Du entwickelst auf einem Rechner **ohne Internetzugang** und musst ein Image auf einen anderen Rechner übertragen.

**Aufgaben:**
1. Welcher Befehl exportiert ein Image als TAR-Datei?
2. Wie importierst du die TAR-Datei auf dem Zielrechner?
3. Werden Tags mit exportiert?

---

## Aufgabe 10: Multi-Stage Build vergleichen

Du hast zwei Images:

**Single-Stage:**
```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
CMD ["node", "dist/app.js"]
```

**Multi-Stage:**
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

**Fragen:**
1. Welches Image wird größer sein?
2. Welche Dateien sind **nur** im Single-Stage Image?
3. Warum ist Multi-Stage in Production besser?

---

## Aufgabe 11: Image-Updates

Du nutzt:
```dockerfile
FROM nginx:1.24
```

Ein Sicherheitsupdate erscheint für nginx:1.24 (neue Layer).

**Fragen:**
1. Hast du automatisch die neue Version, wenn du `docker run` aufrufst?
2. Wie bekommst du die aktualisierte Version?
3. Wie stellst du sicher, dass deine Builds die neueste Version nutzen?

---

## Aufgabe 12: "latest" Tag verstehen

Ein Projekt nutzt:
```dockerfile
FROM python:latest
```

**Probleme:**
- Build funktioniert lokal (Python 3.11)
- CI/CD schlägt fehl (Python 3.12 inkompatibel)

**Fragen:**
1. Warum unterschiedliche Versionen?
2. Wie fixst du das Problem?
3. Warum sollte man `latest` generell vermeiden?

---

## Bonus-Aufgabe: Image-Optimierung

Du hast dieses Image:

```dockerfile
FROM ubuntu:22.04
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y git
RUN apt-get install -y curl
WORKDIR /app
COPY requirements.txt .
RUN pip3 install -r requirements.txt
COPY . .
CMD ["python3", "app.py"]
```

**Aktuell:** 850 MB

**Aufgabe:** Optimiere auf unter 200 MB!

**Hinweise:**
- Nutze ein schlankeres Base-Image
- Kombiniere RUN-Befehle
- Nutze Multi-Stage (falls sinnvoll)
- Cleanup nach apt-get
