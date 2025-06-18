# 🔧 AI Stack Maintenance Guide

## 📋 Quick Maintenance Checklist

### Daily (2 minutes)
```bash
# Quick health check
docker ps
./scripts/check-services.sh
df -h
```

### Weekly (10 minutes)
```bash
# Run automated maintenance
sudo ./scripts/maintenance.sh

# Manual checks
docker stats --no-stream
free -h
```

### Monthly (30 minutes)
```bash
# Full system update
apt update && apt upgrade -y

# Docker maintenance
docker system prune -a
docker compose pull
docker compose up -d

# Consider reboot if uptime > 30 days
uptime
```

## 🚨 When to Restart Server

### ✅ Safe to Continue (No Restart Needed)
- Uptime < 30 days
- Memory usage < 80%
- All services healthy
- Low system load

### ⚠️ Consider Restart
- Uptime > 30 days
- Memory usage > 80%
- High swap usage
- Performance degradation

### 🔴 Restart Required
- Memory usage > 90%
- Services frequently crashing
- System unresponsive
- After kernel updates

## 🔄 Server Restart Procedure

### Before Restart
```bash
# Stop services gracefully
docker compose -f docker-compose.https.yml down
docker compose -f traefik.yml down

# Check for running processes
docker ps -a
```

### Restart
```bash
# Safe restart
sudo reboot

# Or immediate restart if needed
sudo shutdown -r now
```

### After Restart
```bash
# Start services
docker compose -f traefik.yml up -d
docker compose -f docker-compose.https.yml up -d

# Verify all services
./scripts/check-services.sh
```

## 📊 Monitoring Commands

### System Resources
```bash
# Memory and swap
free -h

# Disk usage
df -h

# CPU and load
htop
uptime

# Network
ss -tuln
```

### Docker Resources
```bash
# Container status
docker ps

# Resource usage
docker stats --no-stream

# Disk usage
docker system df

# Logs
docker logs [container_name] --tail 50
```

### AI Services Specific
```bash
# Ollama models
docker exec ollama ollama list

# N8N status
curl http://217.154.225.184:5678

# Open WebUI
curl http://217.154.225.184:3001
```

## 🛠️ Troubleshooting

### Service Not Responding
```bash
# Check logs
docker logs [service_name] --tail 50

# Restart specific service
docker restart [service_name]

# Full service restart
docker compose restart [service_name]
```

### High Memory Usage
```bash
# Identify memory hogs
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Clear cache
sync && echo 3 > /proc/sys/vm/drop_caches

# Consider adding swap
sudo ./scripts/setup-swap.sh
```

### Disk Space Issues
```bash
# Clean Docker
docker system prune -a
docker volume prune

# Clean logs
find /var/log -name "*.log" -mtime +30 -delete

# Check largest directories
du -sh /* | sort -rh | head -10
```

## 📅 Maintenance Schedule

### Optimal Maintenance Windows
- **Daily**: 06:00 UTC (Quick checks)
- **Weekly**: Sunday 02:00 UTC (Updates)
- **Monthly**: First Sunday 02:00 UTC (Full maintenance)

### Automation Setup
```bash
# Add to crontab
crontab -e

# Add these lines:
0 6 * * * /var/www/selfhost/scripts/check-services.sh
0 2 * * 0 /var/www/selfhost/scripts/maintenance.sh
0 2 1 * * systemctl restart docker
```

## 🔒 Security Maintenance

### Regular Security Tasks
```bash
# Check for security updates
apt list --upgradable | grep -i security

# Update Docker
curl -fsSL https://get.docker.com | sh

# Check SSL certificates
openssl x509 -in /var/www/selfhost/ssl/letsencrypt/cert.pem -text -noout
```

### Log Review
```bash
# Check auth logs
tail -f /var/log/auth.log

# Check system logs
journalctl -f

# Check Docker logs
docker events
```

---

## 📞 Emergency Contacts

### Service URLs (Bookmark these)
- Dashboard: http://217.154.225.184:3000
- Open WebUI: http://217.154.225.184:3001
- N8N: http://217.154.225.184:5678
- Traefik: http://217.154.225.184:8080

### Log Locations
- System: `/var/log/`
- Docker: `docker logs [container]`
- AI Stack: `/var/www/selfhost/logs/`
- Maintenance: `/var/www/selfhost/logs/maintenance_*.log`

---

*Keep this guide handy for regular maintenance tasks!*