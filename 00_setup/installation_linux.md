# Installation unter Linux (Ubuntu/Debian)

## 1. Altes aufräumen

```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```

## 2. Repository einrichten

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

## 3. Docker Engine & Compose installieren

```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 4. Rootless Modus (Wichtig!)

Damit du nicht immer `sudo` schreiben musst:

```bash
sudo usermod -aG docker $USER
```

*Danach einmal aus- und einloggen!*

## 5. Test

```bash
docker --version
docker compose version
```
