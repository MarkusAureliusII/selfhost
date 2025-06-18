
# N8N Disaster Recovery Plan

## Überblick

Dieser Disaster Recovery Plan beschreibt die Verfahren zur Sicherung und Wiederherstellung der N8N-Workflow-Automatisierungsplattform im Falle von Systemausfällen, Datenverlusten oder anderen Notfällen.

## Backup-Strategie

### Backup-Typen

1. **Tägliche Backups** (30 Tage Aufbewahrung)
   - Workflows (JSON-Export via API)
   - Credentials (verschlüsselt)
   - N8N Storage Volume
   - N8N Binary Data
   - PostgreSQL Database
   - Konfigurationsdateien

2. **Wöchentliche Backups** (3 Monate Aufbewahrung)
   - Sonntags erstellt
   - Vollständige System-Snapshots

3. **Monatliche Backups** (12 Monate Aufbewahrung)
   - Am 1. jeden Monats erstellt
   - Langzeit-Archivierung

### Backup-Speicherorte

```
/var/www/selfhost/backups/n8n/
├── daily/          # Tägliche Backups (30 Tage)
├── weekly/         # Wöchentliche Backups (90 Tage) 
└── monthly/        # Monatliche Backups (365 Tage)
```

### Automatisierung

- **Tägliche Ausführung**: 02:00 Uhr via Cron
- **Backup-Script**: `/var/www/selfhost/scripts/n8n-backup.sh`
- **Log-Datei**: `/var/www/selfhost/logs/n8n-backup.log`

## Notfall-Szenarien & Lösungen

### Szenario 1: Einzelner Workflow verloren

**Problem**: Ein wichtiger Workflow wurde versehentlich gelöscht oder beschädigt.

**Lösung**:
```bash
# Workflows aus dem letzten Backup wiederherstellen
./scripts/n8n-restore.sh --workflows TIMESTAMP

# Beispiel
./scripts/n8n-restore.sh --workflows 20240618_020000
```

**Recovery Time**: 5-10 Minuten

### Szenario 2: N8N-Datenbank korrupt

**Problem**: PostgreSQL-Datenbank mit N8N-Daten ist beschädigt.

**Lösung**:
```bash
# Nur Datenbank wiederherstellen
./scripts/n8n-restore.sh --database TIMESTAMP

# Beispiel
./scripts/n8n-restore.sh --database 20240618_020000
```

**Recovery Time**: 10-15 Minuten

### Szenario 3: Vollständiger N8N-Ausfall

**Problem**: N8N-Container oder gesamte Anwendung funktioniert nicht mehr.

**Lösung**:
```bash
# Vollständige Wiederherstellung
./scripts/n8n-restore.sh --full TIMESTAMP

# Mit Bestätigung
./scripts/n8n-restore.sh --full 20240618_020000
```

**Recovery Time**: 15-30 Minuten

### Szenario 4: Kompletter Server-Ausfall

**Problem**: Gesamter VPS ist nicht erreichbar oder zerstört.

**Lösung**:
1. **Neuen Server aufsetzen**:
   ```bash
   # Docker und Docker Compose installieren
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   
   # Repository klonen
   git clone <repository> /var/www/selfhost
   cd /var/www/selfhost
   ```

2. **Backups wiederherstellen** (von externem Speicher):
   ```bash
   # Backups auf neuen Server kopieren
   scp -r backups/ user@new-server:/var/www/selfhost/
   
   # Services starten
   docker compose -f docker-compose.https.yml up -d
   
   # Vollständige Wiederherstellung
   ./scripts/n8n-restore.sh --full LATEST_TIMESTAMP
   ```

**Recovery Time**: 1-2 Stunden

## Backup-Verwaltung

### Verfügbare Backups anzeigen

```bash
./scripts/n8n-restore.sh --list
```

### Backup-Integrität prüfen

```bash
./scripts/n8n-restore.sh --verify TIMESTAMP
```

### Manuelles Backup erstellen

```bash
./scripts/n8n-backup.sh
```

## Recovery-Verfahren

### Vor der Wiederherstellung

1. **Backup-Integrität prüfen**:
   ```bash
   ./scripts/n8n-restore.sh --verify TIMESTAMP
   ```

2. **Aktuellen Zustand sichern** (falls möglich):
   ```bash
   ./scripts/n8n-backup.sh
   ```

3. **Services stoppen** (bei Vollwiederherstellung):
   ```bash
   docker compose -f docker-compose.https.yml stop n8n
   ```

### Nach der Wiederherstellung

1. **N8N-Funktionalität testen**:
   - Webinterface erreichbar: http://217.154.225.184:5678
   - Workflows sichtbar und funktionsfähig
   - Credentials verfügbar

2. **Workflow-Tests durchführen**:
   ```bash
   # API-Test
   curl -H "X-N8N-API-KEY: $N8N_API_KEY" \
        http://217.154.225.184:5678/api/v1/workflows
   ```

3. **Log-Dateien prüfen**:
   ```bash
   docker compose -f docker-compose.https.yml logs n8n
   ```

## Monitoring & Wartung

### Täglich
- Backup-Logs prüfen: `/var/www/selfhost/logs/n8n-backup.log`
- Disk-Space überwachen: `df -h`

### Wöchentlich  
- Backup-Integrität testen
- Recovery-Verfahren testen (auf Test-System)

### Monatlich
- Disaster Recovery Plan aktualisieren
- Vollständige Recovery-Tests durchführen

## Wichtige Dateien & Pfade

| Komponente | Pfad | Beschreibung |
|------------|------|--------------|
| Backup-Script | `/var/www/selfhost/scripts/n8n-backup.sh` | Erstellt Backups |
| Restore-Script | `/var/www/selfhost/scripts/n8n-restore.sh` | Stellt Daten wieder her |
| Backup-Verzeichnis | `/var/www/selfhost/backups/n8n/` | Backup-Speicherort |
| Log-Datei | `/var/www/selfhost/logs/n8n-backup.log` | Backup-Protokoll |
| Docker Compose | `/var/www/selfhost/docker-compose.https.yml` | Service-Konfiguration |
| Environment | `/var/www/selfhost/.env` | Umgebungsvariablen |

## Cron-Konfiguration

```bash
# Tägliche Backups um 02:00 Uhr
0 2 * * * /var/www/selfhost/scripts/n8n-backup.sh

# Wöchentliche Backup-Verification (Sonntags um 03:00)
0 3 * * 0 /var/www/selfhost/scripts/backup-health-check.sh
```

## Notfall-Kontakte

- **System-Administrator**: Claude Code Assistant
- **Backup-Speicherort**: Lokaler Server + [Optional: Cloud-Backup]
- **Kritische Services**: N8N, PostgreSQL, Docker

## Testing & Validation

### Monatlicher Recovery-Test

1. Test-Environment aufsetzen
2. Aktuelles Backup in Testumgebung wiederherstellen
3. Funktionalität aller Workflows testen
4. Recovery-Zeit messen
5. Dokumentation aktualisieren

### Backup-Validation

- Automatische Integrität-Checks bei jedem Backup
- Stichproben-Restores in Testumgebung
- Monitoring der Backup-Größen und -Zeiten

## Verbesserungen & Erweiterungen

### Kurz-/Mittelfristig
- [ ] Externe Backup-Speicherung (Cloud/NAS)
- [ ] E-Mail-Benachrichtigungen bei Backup-Fehlern
- [ ] Automatisierte Recovery-Tests
- [ ] Backup-Verschlüsselung

### Langfristig
- [ ] Geo-redundante Backups
- [ ] Real-time Replication für kritische Workflows
- [ ] Disaster Recovery Automation
- [ ] Business Continuity Planning

---

**Letzte Aktualisierung**: $(date)
**Version**: 1.0
**Erstellt von**: Claude Code Assistant