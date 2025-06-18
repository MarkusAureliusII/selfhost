# N8N Backup System - Usage Guide

## Quick Start

### Automatische Backups (bereits konfiguriert)
- **Täglich um 02:00 Uhr**: Vollständige Backups aller N8N-Daten
- **Sonntags um 03:00 Uhr**: Backup-Integritätsprüfung

### Manuelle Backup-Operationen

#### Backup erstellen
```bash
# Sofortiges Backup
/var/www/selfhost/scripts/n8n-backup.sh

# Logs anzeigen
tail -f /var/www/selfhost/logs/n8n-backup.log
```

#### Verfügbare Backups anzeigen
```bash
/var/www/selfhost/scripts/n8n-restore.sh --list
```

#### Backup-Integrität prüfen
```bash
/var/www/selfhost/scripts/n8n-restore.sh --verify 20250618_200837
```

### Restore-Operationen

#### Nur Workflows wiederherstellen
```bash
/var/www/selfhost/scripts/n8n-restore.sh --workflows 20250618_200837
```

#### Nur Datenbank wiederherstellen
```bash
/var/www/selfhost/scripts/n8n-restore.sh --database 20250618_200837
```

#### Vollständige Wiederherstellung (Disaster Recovery)
```bash
# ACHTUNG: Überschreibt alle aktuellen Daten!
/var/www/selfhost/scripts/n8n-restore.sh --full 20250618_200837
```

### Backup-Verzeichnisse

```
/var/www/selfhost/backups/n8n/
├── daily/          # Täglich (30 Tage aufbewahrt)
│   ├── n8n_storage_TIMESTAMP.tar.gz
│   ├── n8n_binary_TIMESTAMP.tar.gz
│   ├── postgres_n8n_TIMESTAMP.sql.gz
│   ├── workflows_TIMESTAMP/
│   ├── config_TIMESTAMP/
│   └── manifest_TIMESTAMP.txt
├── weekly/         # Wöchentlich (90 Tage aufbewahrt)
└── monthly/        # Monatlich (365 Tage aufbewahrt)
```

### Wichtige Befehle

```bash
# Backup-Status prüfen
/var/www/selfhost/scripts/backup-health-check.sh

# Cron-Jobs anzeigen
crontab -l

# N8N-Service Status
docker compose -f /var/www/selfhost/docker-compose.https.yml ps n8n

# Backup-Logs
tail -f /var/www/selfhost/logs/n8n-backup.log
tail -f /var/www/selfhost/logs/backup-health-check.log

# Backup-Größen
du -sh /var/www/selfhost/backups/n8n/*
```

### Troubleshooting

#### Problem: Backup schlägt fehl
1. Überprüfen Sie Docker-Services: `docker compose ps`
2. Prüfen Sie Speicherplatz: `df -h`
3. Logs überprüfen: `tail -f /var/www/selfhost/logs/n8n-backup.log`

#### Problem: Restore funktioniert nicht
1. Backup-Integrität prüfen: `--verify TIMESTAMP`
2. N8N-Service stoppen: `docker compose stop n8n`
3. Manuelle Wiederherstellung durchführen

#### Problem: API-Export fehlgeschlagen
1. N8N_API_KEY in `.env` setzen
2. N8N-API-Zugriff testen: `curl -H "X-N8N-API-KEY: $N8N_API_KEY" http://217.154.225.184:5678/api/v1/workflows`

### Disaster Recovery Szenarien

Siehe: [N8N_DISASTER_RECOVERY_PLAN.md](./N8N_DISASTER_RECOVERY_PLAN.md)

---

**Letzte Aktualisierung**: 2025-06-18
**Version**: 1.0