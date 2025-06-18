#!/bin/bash
# VPS Services Starter - IP+Port Konfiguration

echo "🚀 Starting VPS Services (IP+Port Mode)..."
echo ""

# Docker Networks erstellen falls nicht vorhanden
echo "📊 Creating Docker Networks..."
docker network create demo 2>/dev/null || echo "Network 'demo' already exists"

echo ""
echo "🐳 Starting Services..."

# Hauptservices starten
echo "  ✓ Starting main services..."
docker-compose -f docker-compose.https.yml up -d postgres ollama n8n qdrant dashboard

# Einfacher Traefik starten (nur für Dashboard)
echo "  ✓ Starting simplified Traefik..."
docker-compose -f traefik-simple.yml up -d

echo ""
echo "⏳ Warte auf Service-Start..."
sleep 10

echo ""
echo "✅ Services gestartet!"
echo ""
echo "🌐 Dashboard-Zugriff:"
echo "   📱 Haupt-Dashboard: http://217.154.225.184:3000"
echo ""
echo "🔧 Einzelne Services:"
echo "   • N8N Workflow:    http://217.154.225.184:5678"
echo "   • Qdrant Database: http://217.154.225.184:6333"
echo "   • Traefik Monitor: http://217.154.225.184:8080"
echo "   • Ollama LLM API:  http://217.154.225.184:11434"
echo ""
echo "🔍 Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(dashboard|n8n|qdrant|traefik|ollama|postgres)"

echo ""
echo "💡 Tipps:"
echo "   • Dashboard öffnen: http://217.154.225.184:3000"
echo "   • Status prüfen: docker ps"
echo "   • Logs anzeigen: docker logs <container-name>"
echo "   • Stoppen: docker-compose -f docker-compose.https.yml down"