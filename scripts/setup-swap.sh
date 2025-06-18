#!/bin/bash
# Swap-Konfiguration für VPS
# 4GB Swap für große Ollama-Modelle

echo "=== Swap-Konfiguration für VPS ==="

# Prüfen ob bereits Swap vorhanden
if [ $(swapon --show | wc -l) -gt 0 ]; then
    echo "⚠️  Swap bereits konfiguriert:"
    swapon --show
    free -h
    exit 0
fi

echo "📝 Erstelle 4GB Swap-Datei..."

# 4GB Swap-Datei erstellen
sudo fallocate -l 4G /swapfile

# Berechtigung setzen
sudo chmod 600 /swapfile

# Swap-Signatur erstellen
sudo mkswap /swapfile

# Swap aktivieren
sudo swapon /swapfile

# Permanent in /etc/fstab eintragen
if ! grep -q '/swapfile' /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# Swappiness optimieren (weniger aggressiv swappen)
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

echo "✅ Swap erfolgreich konfiguriert!"
echo ""
echo "📊 Aktuelle Speicher-Konfiguration:"
free -h
echo ""
echo "🔧 Swap Details:"
swapon --show

echo ""
echo "💡 Tipps:"
echo "  - Swappiness auf 10 gesetzt (weniger aggressiv)"
echo "  - Ideal für große Ollama-Modelle"
echo "  - Überwachung mit: watch -n 1 'free -h'"