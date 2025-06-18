#!/bin/bash
# Dashboard Deployment Script - IP+Port Version

echo "🚀 Deploying VPS Dashboard (IP+Port Mode)..."
echo ""

# Docker Network erstellen falls nicht vorhanden
echo "📊 Creating Docker Network..."
docker network create demo 2>/dev/null || echo "Network 'demo' already exists"

# Dashboard Service starten
echo "📊 Starting Dashboard Service..."
docker-compose -f ../docker-compose.https.yml up -d dashboard

echo ""
echo "✅ Dashboard deployed successfully!"
echo ""
echo "🌐 Zugriff über:"
echo "   📱 Haupt-Dashboard: http://217.154.225.184:3000"
echo ""
echo "🔧 Alle verfügbaren Services (IP+Port):"
echo "   • Dashboard: http://217.154.225.184:3000"
echo "   • N8N: http://217.154.225.184:5678"
echo "   • Supabase: http://217.154.225.184:6333" 
echo "   • Traefik: http://217.154.225.184:8080"
echo "   • Ollama: http://217.154.225.184:11434"
echo ""
echo "💡 Dashboard Features:"
echo "   ✓ Übersicht aller Services"
echo "   ✓ Server-Spezifikationen (24GB RAM, 6 CPU)"
echo "   ✓ Direkte Service-Links"
echo "   ✓ Quick Actions"
echo "   ✓ Responsive Design"
echo ""
echo "🔍 Status prüfen:"
docker ps | grep dashboard
echo ""
echo "🚀 Alle Services starten: ../start-services.sh"
echo "🔍 Service Check: ../check-services.sh"