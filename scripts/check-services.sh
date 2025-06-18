#!/bin/bash
# Port Status Check für alle VPS Services

echo "🔍 VPS Service Status Check"
echo "════════════════════════════════════════"
echo ""

# Farben für Output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# IP Address
VPS_IP="217.154.225.184"

# Services to check
declare -A SERVICES=(
    ["Dashboard"]="3000"
    ["N8N"]="5678"
    ["Qdrant"]="6333"
    ["Traefik"]="8080"
    ["Ollama"]="11434"
)

echo "📊 Checking Service Ports on $VPS_IP..."
echo ""

# Check each service
for service in "${!SERVICES[@]}"; do
    port=${SERVICES[$service]}
    url="http://$VPS_IP:$port"
    
    printf "%-15s (Port %s): " "$service" "$port"
    
    # Check if port is listening
    if nc -z -w3 $VPS_IP $port 2>/dev/null; then
        echo -e "${GREEN}✓ ONLINE${NC} - $url"
    else
        echo -e "${RED}✗ OFFLINE${NC} - $url"
    fi
done

echo ""
echo "🐳 Docker Container Status:"
echo "────────────────────────────────────────"
if command -v docker &> /dev/null; then
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | head -1
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(dashboard|n8n|qdrant|traefik|ollama|postgres)" | head -10
else
    echo "Docker not available"
fi

echo ""
echo "🌐 Network Connectivity Test:"
echo "────────────────────────────────────────"

# Test external connectivity
printf "Internet: "
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${GREEN}✓ Connected${NC}"
else
    echo -e "${RED}✗ No Connection${NC}"
fi

# Test DNS
printf "DNS: "
if nslookup google.com &> /dev/null; then
    echo -e "${GREEN}✓ Working${NC}"
else
    echo -e "${RED}✗ Failed${NC}"
fi

echo ""
echo "💾 System Resources:"
echo "────────────────────────────────────────"

# RAM Usage
echo "RAM Usage:"
free -h | grep -E '^Mem'

# Disk Usage
echo ""
echo "Disk Usage:"
df -h | grep -E '^/dev.*/$'

# Load Average
echo ""
echo "System Load:"
uptime

echo ""
echo "🔧 Quick Commands:"
echo "────────────────────────────────────────"
echo "  Start Services: ./start-services.sh"
echo "  View Logs:      docker logs <container-name>"
echo "  Restart:        docker-compose restart <service>"
echo "  Stop All:       docker-compose down"

echo ""
echo "📱 Access Dashboard: http://$VPS_IP:3000"