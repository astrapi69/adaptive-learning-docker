# Drill-Ergebnisse & Fehlerprävention

## Wichtige Unterscheidungen
- `docker volume ls`: Liste ALLER Volumes.
- `docker volume inspect NAME`: Details eines SPEZIFISCHEN Volumes.
- `docker volume prune`: Räumt alle ungenutzten Volumes auf.

## Sicherheitsmechanismus
Für `docker volume rm` gibt es **kein** `-f` Flag. Der Container muss zuerst gelöscht werden, bevor das Volume entfernt werden kann.
