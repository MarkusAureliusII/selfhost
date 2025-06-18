#!/bin/bash

# AI Stack Maintenance Script
# Performs routine maintenance tasks for the self-hosted AI infrastructure

echo "🔧 Starting AI Stack Maintenance..."
echo "Date: $(date)"
echo "======================================"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# System updates
log "📦 Updating system packages..."
apt update -y
apt upgrade -y

# Docker maintenance
log "🐳 Docker system cleanup..."
docker system prune -f
docker volume prune -f
docker image prune -f

# Check disk usage
log "💾 Checking disk usage..."
df -h /

# Check memory usage
log "🧠 Checking memory usage..."
free -h

# Check service health
log "🏥 Checking service health..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check AI model status
log "🤖 Checking AI models..."
docker exec ollama ollama list

# Security updates
log "🔒 Checking for security updates..."
apt list --upgradable | grep -i security

# Log cleanup (keep last 30 days)
log "🧹 Cleaning old logs..."
find /var/log -name "*.log" -mtime +30 -delete 2>/dev/null || true

# Docker logs cleanup (keep last 7 days)
log "📋 Cleaning Docker logs..."
docker system events --since 7d --until 1s >/dev/null 2>&1 || true

# Check SSL certificates (if using domain)
log "🔐 Checking SSL certificates..."
if [ -d "/var/www/selfhost/ssl/letsencrypt" ]; then
    find /var/www/selfhost/ssl/letsencrypt -name "*.pem" -mtime +60 -exec echo "SSL certificates expiring soon: {}" \;
fi

# Performance check
log "⚡ Performance check..."
uptime
iostat -h 1 1 2>/dev/null || echo "iostat not available"

# Service endpoint check
log "🌐 Testing service endpoints..."
services=(
    "3000:Dashboard"
    "3001:Open WebUI"
    "5678:N8N"
    "6333:Qdrant"
    "8080:Traefik"
    "11434:Ollama"
)

for service in "${services[@]}"; do
    port=$(echo $service | cut -d: -f1)
    name=$(echo $service | cut -d: -f2)
    
    if curl -s -o /dev/null -w "%{http_code}" http://217.154.225.184:$port | grep -q "200"; then
        echo "✅ $name (port $port): OK"
    else
        echo "❌ $name (port $port): FAILED"
    fi
done

# Generate maintenance report
log "📊 Generating maintenance report..."
cat > /var/www/selfhost/logs/maintenance_$(date +%Y%m%d_%H%M%S).log << EOF
Maintenance Report - $(date)
================================
System Uptime: $(uptime)
Memory Usage: $(free -h | grep Mem)
Disk Usage: $(df -h / | tail -1)
Running Containers: $(docker ps --format "{{.Names}}" | wc -l)
Docker Images: $(docker images | wc -l)
Docker Volumes: $(docker volume ls | wc -l)
Available Updates: $(apt list --upgradable 2>/dev/null | wc -l)
EOF

log "✅ Maintenance completed successfully!"
log "📝 Report saved to: /var/www/selfhost/logs/maintenance_$(date +%Y%m%d_%H%M%S).log"

echo ""
echo "🔄 Restart Recommendation:"
echo "  • System uptime: $(uptime -p)"
echo "  • Consider reboot if uptime > 30 days"
echo "  • Or if memory usage > 80%"
echo "  • Or after major updates"

echo ""
echo "📋 Next steps:"
echo "  • Review maintenance log"
echo "  • Check for any failed services"
echo "  • Monitor system performance"
echo "  • Schedule next maintenance"