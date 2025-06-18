#!/bin/bash
# Monitoring & Management Scripts für VPS
# Debian 12, 6 CPU Cores, 24GB RAM, 360GB SSD

echo "=== VPS Ressourcen-Monitor ==="

# Live Container Stats
echo "📊 Container Ressourcen-Nutzung:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}"

echo ""
echo "🖥️  System Ressourcen:"

# CPU Info
echo "CPU Kerne: $(nproc)"
echo "CPU Last: $(uptime | awk -F'load average:' '{ print $2 }')"

# RAM Usage
free -h | grep -E '^Mem|^Swap'

echo ""
echo "💾 Speicher-Nutzung:"

# Disk Usage
df -h | grep -E '^/dev|Size'

echo ""
echo "🐳 Docker System:"

# Docker System Info
docker system df

echo ""
echo "📈 Top Prozesse nach RAM:"
ps aux --sort=-%mem | head -5

echo ""
echo "🔥 Top Prozesse nach CPU:"
ps aux --sort=-%cpu | head -5

echo ""
echo "🌐 Netzwerk Ports:"
netstat -tulpn | grep LISTEN | head -10

# Ollama Model Info (wenn Container läuft)
if docker ps | grep -q ollama; then
    echo ""
    echo "🤖 Ollama Modelle:"
    docker exec ollama ollama list 2>/dev/null || echo "Ollama nicht verfügbar"
fi

echo ""
echo "=== Für kontinuierliches Monitoring ==="
echo "Befehle:"
echo "  watch -n 2 'docker stats --no-stream'"
echo "  htop"
echo "  docker logs -f <container-name>"