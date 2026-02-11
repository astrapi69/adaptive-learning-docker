# Lösungen: Volumes & Persistenz
1. `docker volume create db_data`
2. `docker run -d --name my_db -v db_data:/var/lib/postgresql/data postgres`
3. Fehler. Docker verhindert das Löschen von Volumes, die noch einem (auch gestoppten) Container zugewiesen sind.
4. Bind Mounts beginnen mit einem Pfad (`/` oder `./`), Named Volumes nutzen nur einen Namen (z.B. `-v mein-volume:/pfad`).
