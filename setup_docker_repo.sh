#!/bin/bash

REPO_NAME="docker-learning-journey"
mkdir -p $REPO_NAME
cd $REPO_NAME

# Unterverzeichnisse (Jetzt mit 00_setup)
mkdir -p 00_setup 01_grundlagen 02_lifecycle 03_volumes 04_docker_compose

# --- 00 SETUP (Installation) ---
cat <<EOF > 00_setup/installation_linux.md
# Installation unter Linux (Ubuntu/Debian)

## 1. Altes aufräumen
\`\`\`bash
sudo apt-get remove docker docker-engine docker.io containerd runc
\`\`\`

## 2. Repository einrichten
\`\`\`bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(. /etc/os-release && echo "\$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
\`\`\`

## 3. Docker Engine & Compose installieren
\`\`\`bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
\`\`\`

## 4. Rootless Modus (Wichtig!)
Damit du nicht immer \`sudo\` schreiben musst:
\`\`\`bash
sudo usermod -aG docker \$USER
\`\`\`
*Danach einmal aus- und einloggen!*

## 5. Test
\`\`\`bash
docker --version
docker compose version
\`\`\`
EOF

# --- 00 SETUP AUFGABEN ---
cat <<EOF > 00_setup/aufgaben.md
# Aufgaben: Installation
1. Installiere Docker nach der Anleitung.
2. Warum sollte man seinen User zur Gruppe "docker" hinzufügen?
3. Was ist der Unterschied zwischen dem alten "docker-compose" und dem neuen "docker compose"?
EOF

cat <<EOF > 00_setup/loesungen.md
# Lösungen: Installation
1. (Praktische Ausführung)
2. Um Docker-Befehle ohne \`sudo\` ausführen zu können (erhöht den Komfort, birgt aber Sicherheitsrisiken).
3. "docker-compose" (mit Bindestrich) war ein separates Python-Tool (V1). Das neue "docker compose" (V2) ist direkt in die Docker-CLI integriert (in Go geschrieben) und performanter.
EOF

# [Hier folgen die restlichen Blöcke für 01 bis 04 aus dem vorherigen Script...]
# (Ich kürze das hier ab, damit es übersichtlich bleibt)

echo "✅ Struktur inklusive Installations-Guide erstellt!"
