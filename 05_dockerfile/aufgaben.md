# Aufgaben: Dockerfile Best Practices

## Aufgabe 1: Layer-Caching verstehen

Ein Entwickler liefert dir dieses Dockerfile:

```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "app.js"]
```

**Fragen:**
1. Was passiert beim **zweiten Build**, wenn du nur eine Zeile in `app.js` änderst?
2. Warum ist das problematisch?
3. Wie optimierst du das Dockerfile für besseres Caching?

---

## Aufgabe 2: Cache-Optimierung

Ordne diese Dockerfile-Zeilen in die **optimale Reihenfolge** für Layer-Caching:

```dockerfile
CMD ["node", "app.js"]
COPY . .
RUN npm install
FROM node:18
COPY package*.json ./
WORKDIR /app
```

**Frage:** Warum ist genau diese Reihenfolge optimal?

---

## Aufgabe 3: Port-Mapping & Dockerfile

Du hast dieses Dockerfile:

```dockerfile
FROM nginx:1.25
COPY index.html /usr/share/nginx/html/
```

**Fragen:**
1. Wie startest du einen Container aus diesem Image auf Port **8080** (Host)?
2. Auf welchem Port läuft nginx **im Container**? (Tipp: nginx default)
3. Warum steht kein `EXPOSE` im Dockerfile?

---

## Aufgabe 4: Secrets-Problem erkennen

Ein Kollege zeigt dir dieses Dockerfile:

```dockerfile
FROM node:18
WORKDIR /app
COPY .env /app/.env
COPY package*.json ./
RUN npm install
COPY . .
RUN rm /app/.env              # "Secrets löschen"
CMD ["node", "app.js"]
```

**Fragen:**
1. Warum ist das **NICHT sicher**, obwohl `.env` gelöscht wird?
2. Wie kann jemand den Secret trotzdem auslesen?
3. Wie übergibt man Secrets **richtig**?

---

## Aufgabe 5: Multi-Stage Build

Du baust eine React-App. Build braucht `npm run build`, Runtime nur statische Files.

**Aufgabe:** Schreibe ein Dockerfile mit **2 Stages**:
- Stage 1: Baut die App (`npm run build` → `/app/build/`)
- Stage 2: Nginx serviert nur die Build-Files

**Skeleton:**
```dockerfile
# Stage 1: Build
FROM node:18 AS builder
# ... dein Code ...

# Stage 2: Production
FROM nginx:alpine
# ... dein Code ...
```

---

## Aufgabe 6: .dockerignore nutzen

Du hast folgende Projekt-Struktur:

```
my-app/
├── node_modules/       # 300 MB
├── .git/               # 50 MB
├── src/
│   └── app.js
├── package.json
├── README.md
└── Dockerfile
```

Dein Dockerfile:
```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "src/app.js"]
```

**Fragen:**
1. Was wird alles ins Image kopiert?
2. Welche Dateien sollten in `.dockerignore`?
3. Warum ist `node_modules/` problematisch beim `COPY . .`?

---

## Aufgabe 7: WORKDIR verstehen

Was ist der Unterschied zwischen diesen beiden Dockerfiles?

**Variante A:**
```dockerfile
FROM node:18
COPY package.json /app/package.json
RUN cd /app && npm install
COPY . /app
CMD cd /app && node app.js
```

**Variante B:**
```dockerfile
FROM node:18
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
CMD ["node", "app.js"]
```

**Fragen:**
1. Welches ist besser? Warum?
2. Was macht `WORKDIR`?

---

## Aufgabe 8: Image-Build debuggen

Du führst aus:
```bash
docker build -t myapp .
```

Der Build schlägt bei `RUN npm install` fehl:
```
Error: Cannot find module 'express'
```

**Fragen:**
1. Wo könnte das Problem liegen?
2. Wie prüfst du, welche Dateien tatsächlich ins Image kopiert wurden?
3. Welcher Befehl zeigt dir, was in jedem Layer passiert ist?

---

## Aufgabe 9: Security - Non-Root User

Du baust ein Production-Image. Security-Team sagt: "Container darf nicht als root laufen!"

**Aufgabe:** Erweitere dieses Dockerfile, damit die App als User `node` läuft:

```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["node", "app.js"]
```

**Hinweis:** User `node` existiert bereits im node-Image

---

## Aufgabe 10: Cache invalidieren (Troubleshooting)

Du änderst `package.json` (neue Dependency), aber `docker build` installiert sie nicht.

**Fragen:**
1. Was ist wahrscheinlich passiert?
2. Wie baust du das Image **ohne Cache** neu?
3. Wann solltest du das tun?

---

## Bonus-Aufgabe: Komplettes Dockerfile schreiben

**Scenario:** Du hast eine Python Flask-App:

```
flask-app/
├── requirements.txt
├── app.py
└── templates/
    └── index.html
```

**Anforderungen:**
1. Base-Image: `python:3.11-slim`
2. Arbeitsverzeichnis: `/app`
3. Dependencies aus `requirements.txt` installieren
4. App läuft auf Port 5000
5. **Optimiert** für Layer-Caching
6. Läuft als non-root User

**Schreibe das komplette Dockerfile.**
