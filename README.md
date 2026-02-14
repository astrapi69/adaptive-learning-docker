# Docker Lernreise 2026 🐳

Dieses Repository dokumentiert meinen Fortschritt beim Erlernen von Docker, fokussiert auf QA-Automation und
Datenbank-Containerisierung.

## 📊 Aktueller Status (Stand: Feb 14, 2026)

| Metrik                         | Wert     |
|--------------------------------|----------|
| **Verständnis-Level**          | 9/10     |
| **Transferfähigkeit**          | 10/10    |
| **Fehlerquote (Start → Ende)** | 70% → 0% |
| **Gemeisterte Zyklen**         | 4/4      |

**Aktueller Fokus:** Docker Compose & Multi-Container-Kommunikation ✅

---

## 🎯 Lernziele

### Phase 1: Grundlagen (Abgeschlossen ✅)

- [x] Docker Kernkonzepte (Image vs. Container)
- [x] Container-Lifecycle Management (start/stop/rm)
- [x] Datenpersistenz mit Volumes
- [x] Multi-Container Setups mit Docker Compose
- [x] Service-zu-Service Kommunikation via DNS

### Phase 2: Advanced (Geplant)

- [ ] Dockerfile schreiben (eigene Images bauen)
- [ ] Java-Apps in Docker deployen
- [ ] Custom Docker Networks
- [ ] Docker Compose Stack (Production Features)
- [ ] Multi-Stage Builds
- [ ] QA-Automation mit Testcontainers

### Phase 3: Production & CI/CD (Zukunft)

- [ ] Docker in CI/CD Pipelines (GitHub Actions, Jenkins)
- [ ] Container-Orchestrierung (Docker Swarm Basics)
- [ ] Security Best Practices
- [ ] Performance-Optimierung

---

## 📚 Repository-Struktur

```
adaptive-learning-docker/
├── 00_setup/                # Installation & Erste Schritte
│   ├── installation_linux.md
│   ├── aufgaben.md
│   └── loesungen.md
│
├── 01_grundlagen/           # Docker Kernkonzepte
│   ├── kernkonzepte.md      # Image vs. Container (Java-Analogie)
│   ├── aufgaben.md
│   └── loesungen.md
│
├── 02_lifecycle/            # Container Management
│   ├── container_management.md
│   ├── aufgaben.md
│   └── loesungen.md
│
├── 03_volumes/              # Datenpersistenz
│   ├── persistenz.md        # Named Volumes vs. Bind Mounts
│   ├── drill_training.md    # ls vs inspect Übungen
│   ├── aufgaben.md
│   └── loesungen.md
│
├── 04_docker_compose/       # Multi-Container Setups
│   ├── multi_container.md
│   ├── docker-compose.yml   # PostgreSQL + Redis Beispiel
│   ├── aufgabe-docker-compose.yml  # MySQL + Redis (eigene Arbeit)
│   ├── example-postgres_redis-docker-compose.yml
│   ├── aufgaben.md
│   └── loesungen.md
│
├── CHEATSHEET.md            # Quick Reference aller Befehle
├── LEARNING_STATS.md        # Detaillierte Lernstatistik
├── ROADMAP.md               # Nächste Schritte & Planung
└── README.md                # Diese Datei
```

---

## 🏆 Erreichte Meilensteine

### Zyklus #1: Docker Grundlagen

- ✅ Image vs. Container Konzept (perfekte Java-Analogie entwickelt)
- ✅ `docker run` mit allen wichtigen Flags
- ✅ Container-Status prüfen (`ps`, `ps -a`)

### Zyklus #2: Container-Lifecycle

- ✅ `start`, `stop`, `restart`, `rm` Befehle
- ✅ Force-Delete (`rm -f`)
- ✅ Unterschied zwischen stoppen und löschen

### Zyklus #3: Volumes & Persistenz

- ✅ Named Volumes vs. Bind Mounts verstanden
- ✅ Volume-Befehle (`ls`, `inspect`, `prune`, `create`, `rm`)
- ✅ **Drill-Training:** Fehlerquote von 70% auf 0% reduziert
- ✅ Syntax-Automatisierung (`:` vs `=`)

### Zyklus #4: Docker Compose

- ✅ `docker-compose.yml` Syntax gemeistert
- ✅ Multi-Container-Setup fehlerfrei erstellt (MySQL + Redis)
- ✅ Service-zu-Service Kommunikation via DNS
- ✅ Compose-Befehle (`up`, `down`, `ps`, `logs`)
- ✅ Volume-Management in Compose

---

## 💡 Key Learnings & Best Practices

### 1. Mental Models

**Image = Klasse, Container = Instanz** (Java/OOP-Analogie)

- Ein Image kann viele Container erzeugen
- Container sind unabhängige Instanzen

### 2. Syntax-Regeln

```bash
# Mappings (Ports, Volumes): Doppelpunkt
-p 5432:5432
-v pgdata:/var/lib/postgresql/data

# Env-Variablen: Gleichheitszeichen
-e POSTGRES_PASSWORD=secret
```

### 3. Volume-Typen unterscheiden

```bash
# Named Volume (kein Pfad-Präfix)
-v mydata:/container/path

# Bind Mount (beginnt mit / oder ./)
-v /home/user/data:/container/path
```

### 4. Service-Kommunikation in Compose

Services erreichen sich über **Service-Namen als Hostname**:

```yaml
services:
  db:
    image: postgres
  app:
    image: my-app
    # Connection: jdbc:postgresql://db:5432/mydb
```

### 5. Daten-Persistenz

- `docker compose down` → Container weg, **Volumes bleiben**
- `docker compose down -v` → Container + Volumes weg

---

## 🎓 Verwendete Lernmethoden

1. **Adaptive Lernzyklen**
    - Mini-Erklärung → Beispiel → Anwendung → Feedback → Transfer-Test

2. **Fehlerklassifikation**
    - Konzeptfehler vs. Prozedurfehler vs. Aufmerksamkeitsfehler
    - Gezielte Behebung durch Drill-Training

3. **Drill-Training**
    - Wiederholte Übungen für hartnäckige Fehler
    - Beispiel: `ls` vs `inspect` - von 70% auf 0% Fehlerquote

4. **Transfer-Tests**
    - Anwendung in neuen Kontexten ohne Hinweise
    - Beweis für echtes Verständnis

---

## 📖 Ressourcen & Links

- **Docker Docs:** https://docs.docker.com/
- **Docker Compose Docs:** https://docs.docker.com/compose/
- **Best Practices:** https://docs.docker.com/develop/dev-best-practices/

---

## 🚀 Nächste Schritte

Siehe [ROADMAP.md](ROADMAP.md) für detaillierte Planung.

**Kurzfristig (nächste Session):**

- Dockerfile schreiben lernen
- Erste Java-App containerisieren
- Custom Networks verstehen

**Mittelfristig:**

- QA-spezifische Use Cases implementieren
- Selenium Grid in Docker
- Database Testing Setups

---

## 📈 Lernfortschritt

Detaillierte Statistiken und Fehleranalysen in [LEARNING_STATS.md](LEARNING_STATS.md)

**Highlights:**

- Fehlerquote Start: 70% → Ende: 0%
- Verständnis-Level konstant bei 9-10/10
- Transferfähigkeit: 10/10 in allen Zyklen

---

## 🛠️ Praktische Anwendungsfälle

### QA-Testing Setup

```yaml
# docker-compose.yml für Integrationstests
services:
  test-db:
    image: postgres
    environment:
      POSTGRES_DB: testdb
      POSTGRES_PASSWORD: test
    ports:
      - "5432:5432"
```

### Dev-Umgebung (keine lokale DB-Installation nötig)

```bash
# PostgreSQL für lokale Entwicklung
docker run --name dev-postgres \
  -e POSTGRES_PASSWORD=dev \
  -p 5432:5432 \
  -v pgdata:/var/lib/postgresql/data \
  postgres
```

---

## 📝 Notizen & Erkenntnisse

- **Spacing-Empfehlung:** Wiederholung nach 24h, 7 Tagen, 1 Monat
- **Beste Methode für mich:** Strukturierte Zyklen mit sofortigem Feedback
- **Erfolgsfaktor:** Drill-Training für Syntax-Automatisierung
- **Transfer-Schlüssel:** Analogien zu bekannten Konzepten (OOP)

---

## 📄 Lizenz

MIT License - siehe [LICENSE](LICENSE)

---

**Stand:** Feb 14, 2026 | **Status:** Phase 1 abgeschlossen ✅
