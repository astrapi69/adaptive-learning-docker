# Docker Volumes & Persistenz

## Key-Learnings

- **Named Volumes:** `-v name:/pfad` (Docker verwaltet den Speicherort).
- **Bind Mounts:** `-v /absoluter/pfad:/pfad` (Du bestimmst den Ort, Pfad beginnt mit `/` oder `./`).

## Syntax-Regeln

- **Mappings (Ports, Volumes):** Nutzen den Doppelpunkt `:`.
- **Umgebungsvariablen:** Nutzen das Gleichheitszeichen `=`.
