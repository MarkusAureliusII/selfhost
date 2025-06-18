# Installation Guide

## Quick Start

### 1. Prerequisites
- VPS with root access
- Debian 12 or similar Linux distribution
- 4GB+ RAM (24GB recommended for AI workloads)
- 50GB+ storage (360GB recommended)
- Internet connection

### 2. Download Project
```bash
# Upload or clone project to VPS
cd /var/www/selfhost
```

### 3. Initial Setup
```bash
# Install Docker
chmod +x scripts/get-docker.sh
./scripts/get-docker.sh

# Setup swap space
chmod +x scripts/setup-swap.sh
./scripts/setup-swap.sh

# Create Docker networks
docker network create web
docker network create demo
```

### 4. Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit with your values
nano .env
```

### 5. Start Services
```bash
# Start reverse proxy
docker compose -f traefik.yml up -d

# Start AI stack
docker compose -f docker-compose.https.yml up -d

# Check status
./scripts/check-services.sh
```

### 6. Access Services
- Dashboard: http://your-ip:3000
- Open WebUI: http://your-ip:3001
- N8N: http://your-ip:5678
- Ollama API: http://your-ip:11434

## Troubleshooting

See README.md for detailed troubleshooting guide.