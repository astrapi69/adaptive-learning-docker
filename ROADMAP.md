# Docker Lernreise - Roadmap 🗺️

## Status Overview

**Aktueller Stand:** Phase 1 abgeschlossen ✅  
**Nächste Phase:** Phase 2 - Advanced Docker  
**Langfristziel:** Production-ready Docker-Setups für QA-Automation

---

## Phase 1: Grundlagen ✅ (Abgeschlossen)

**Zeitraum:** Feb 14, 2026  
**Status:** 100% abgeschlossen

### Erreichte Meilensteine:

- [x] Docker Installation & Setup
- [x] Image vs. Container Konzept
- [x] Container-Lifecycle Management
- [x] Volumes & Datenpersistenz
- [x] Docker Compose Basics
- [x] Multi-Container Kommunikation

### Metriken:

- Verständnis-Level: 9/10
- Transferfähigkeit: 10/10
- Fehlerquote: 0% (Start: 70%)

---

## Phase 2: Advanced Docker 🎯 (Aktuell)

**Geschätzte Dauer:** 2-3 Sessions  
**Priorität:** Hoch  
**Start:** Geplant für nächste Session

### Ziele:

#### 1. Dockerfile & Image Building 🔨

**Warum wichtig:** Eigene Java-Apps containerisieren

- [ ] Dockerfile Syntax lernen
    - `FROM`, `COPY`, `RUN`, `CMD`, `ENTRYPOINT`
    - Multi-stage builds Konzept
    - Layer Caching verstehen

- [ ] Erste eigene Images bauen
    - Java-App containerisieren (Maven/Gradle)
    - .dockerignore nutzen
    - Image-Größe optimieren

- [ ] Best Practices
    - Minimale Base-Images (Alpine)
    - Security: Non-root User
    - Secrets nicht im Image

**Erwartete Fehlerquote Start:** 25-30%  
**Ziel Ende:** < 10%

**Praxisaufgabe:** Spring Boot App als Docker Image bauen

---

#### 2. Docker Networks 🌐

**Warum wichtig:** Isolation & Sicherheit in Multi-Container-Setups

- [ ] Network-Typen verstehen
    - Bridge (Standard)
    - Host
    - None
    - Custom Bridge

- [ ] Custom Networks erstellen
    - Container in separaten Netzwerken
    - Network-Isolation für Security
    - Container über Netzwerke verbinden

- [ ] DNS & Service Discovery
    - Wie Docker DNS intern funktioniert
    - Custom DNS-Namen vergeben

**Praxisaufgabe:** QA-Setup mit isolierten Netzwerken (Frontend <-> Backend <-> DB)

---

#### 3. Docker Compose Advanced 📋

**Warum wichtig:** Production-ready Setups

- [ ] Environment Files (.env)
    - Secrets aus Compose-Files fernhalten
    - Unterschiedliche Envs (dev/test/prod)

- [ ] Health Checks
    - Container-Gesundheit überwachen
    - Depends_on mit Health Checks

- [ ] Resource Limits
    - CPU & Memory Limits setzen
    - Prevent resource exhaustion

- [ ] Profiles
    - Verschiedene Service-Kombinationen (dev vs prod)

**Praxisaufgabe:** Production-ready Compose-File mit Health Checks & Limits

---

## Phase 3: QA-Specific Use Cases 🧪 (Geplant)

**Geschätzte Dauer:** 3-4 Sessions  
**Priorität:** Mittel  
**Start:** Nach Phase 2

### Ziele:

#### 1. Database Testing Automation

- [ ] Testcontainers Library nutzen
    - Programmatisch Container starten/stoppen
    - Integration Tests mit echten DBs

- [ ] Database Migration Testing
    - Flyway/Liquibase in Docker
    - Rollback-Szenarien testen

- [ ] Performance Testing
    - Last-Tests gegen containerisierte DBs
    - Resource-Monitoring

**Praxisaufgabe:** Integrationstests mit Testcontainers für Java-App

---

#### 2. Selenium Grid in Docker 🌐

- [ ] Selenium Grid Setup
    - Hub + Nodes in Compose
    - Browser-Container (Chrome, Firefox)

- [ ] Parallele Tests
    - Multiple Nodes für Speed
    - Dynamische Skalierung

- [ ] Video Recording
    - Test-Läufe aufzeichnen
    - Debugging bei Fehlern

**Praxisaufgabe:** Komplettes Selenium Grid für UI-Tests

---

#### 3. Mock Services & Test Data

- [ ] WireMock in Docker
    - API-Mocks für Tests
    - Test-Szenarien simulieren

- [ ] Test-Datenbank-Seeds
    - Vorgefüllte DBs für Tests
    - Fixtures automatisch laden

**Praxisaufgabe:** Mock-API-Service für Integrationstests

---

## Phase 4: CI/CD Integration 🚀 (Zukunft)

**Geschätzte Dauer:** 2-3 Sessions  
**Priorität:** Niedrig (erst nach Phase 3)  
**Start:** TBD

### Ziele:

#### 1. Docker in CI Pipelines

- [ ] GitHub Actions mit Docker
    - Build, Test, Push Workflow
    - Matrix Tests (verschiedene DB-Versionen)

- [ ] Docker Hub / Registry
    - Images pushen/pullen
    - Private Registry

- [ ] Caching Strategien
    - Layer Cache in CI
    - Build-Zeit optimieren

---

#### 2. Container Orchestration Basics

- [ ] Docker Swarm Einführung
    - Services deployen
    - Scaling
    - Load Balancing

- [ ] Docker Compose in Production
    - docker-compose vs docker stack
    - Swarm Secrets

**Note:** Kubernetes bewusst ausgelassen (zu komplex für aktuellen Bedarf)

---

## Phase 5: Production & Security 🔒 (Langfristig)

**Geschätzte Dauer:** 3-4 Sessions  
**Priorität:** Niedrig  
**Start:** TBD

### Ziele:

#### 1. Security Best Practices

- [ ] Image Scanning
    - Vulnerability Detection
    - Trivy / Clair

- [ ] Secrets Management
    - Docker Secrets
    - External Secrets (Vault)

- [ ] Least Privilege
    - Non-root Container
    - Read-only Filesystems

---

#### 2. Monitoring & Logging

- [ ] Container-Logs aggregieren
    - Centralized Logging (ELK Stack)

- [ ] Metrics & Monitoring
    - Prometheus + Grafana
    - Container Performance

---

#### 3. Performance Optimization

- [ ] Image-Größe reduzieren
    - Multi-stage Builds
    - Distroless Images

- [ ] Build-Zeit optimieren
    - Layer Caching
    - BuildKit Features

---

## 📅 Timeline & Priorisierung

### Nächste 2 Wochen (High Priority)

1. **Dockerfile schreiben** (Session 1)
    - Java-App containerisieren
    - Multi-stage builds

2. **Docker Networks** (Session 2)
    - Custom Networks erstellen
    - Network-Isolation

### Nächste 4 Wochen (Medium Priority)

3. **Compose Advanced** (Session 3)
    - Health Checks
    - .env Files

4. **Testcontainers** (Session 4)
    - Integration Tests
    - Database Testing

### Nächste 2-3 Monate (Low Priority)

5. CI/CD Integration
6. Selenium Grid
7. Production Setups

---

## 🎯 Erfolgskriterien pro Phase

### Phase 2 (Advanced)

- Eigenständig Dockerfile für Java-App schreiben (0 Fehler)
- Custom Network Setup ohne Dokumentation erstellen
- Production-ready Compose-File mit Health Checks

### Phase 3 (QA Use Cases)

- Testcontainer-basierte Integration Tests schreiben
- Selenium Grid Compose-Setup lauffähig
- Mock-Services für Test-Automation nutzen

### Phase 4 (CI/CD)

- GitHub Actions Pipeline mit Docker-Build
- Automatische Tests in CI
- Image-Publishing funktioniert

---

## 🔄 Iterativer Ansatz

Jede Phase folgt dem bewährten Pattern:

1. **Mini-Erklärung** (Konzepte verstehen)
2. **Beispiele** (Best Practices sehen)
3. **Hands-on** (Eigenständig umsetzen)
4. **Drill-Training** (bei Syntax-Problemen)
5. **Transfer-Test** (Neuer Kontext, ohne Hilfe)

**Ziel pro Phase:** < 10% Fehlerquote am Ende

---

## 📊 Tracking & Anpassung

**Review nach jeder Session:**

- Fehlerquote dokumentieren
- Gemeisterte Konzepte markieren
- Roadmap bei Bedarf anpassen

**Langfristige Anpassungen:**

- Neue Use Cases aus der Arbeit integrieren
- Technologie-Updates berücksichtigen
- Priorisierung nach Bedarf ändern

---

## 🎓 Lernressourcen pro Phase

### Phase 2

- Docker Docs: Dockerfile Reference
- Best Practices Guide
- Multi-stage Build Tutorial

### Phase 3

- Testcontainers Docs
- Selenium Grid Docker Hub
- WireMock Documentation

### Phase 4

- GitHub Actions Docs
- Docker Registry Guide

---

## 🚀 Quick Wins (Nebenbei)

Kleine Verbesserungen parallel zu den Phasen:

- [ ] Docker CLI Aliases einrichten (`dps` = `docker ps`)
- [ ] VSCode Docker Extension nutzen
- [ ] Docker Compose file Autocomplete
- [ ] Eigene docker-compose Templates für häufige Setups
- [ ] Cheat Sheet als PDF für schnellen Zugriff

---

## 💡 Notizen & Anpassungen

**Learnings aus Phase 1:**

- Drill-Training extrem effektiv bei Syntax-Problemen
- Transfer-Tests sind Pflicht (decken Wissenslücken auf)
- OOP-Analogien beschleunigen Verständnis massiv

**Anpassungen für Phase 2:**

- Mehr praktische Aufgaben (weniger Theorie)
- Sofortiges Feedback beibehalten
- Eigene Projekte aus der Arbeit integrieren

---

