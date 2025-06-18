#!/bin/bash

# N8N Daily Backup Script
# Erstellt tägliche Backups von N8N Workflows, Credentials und Datenbank
# Author: Claude Code Assistant
# Version: 1.0

set -e  # Exit on any error

# Configuration
BACKUP_DIR="/var/www/selfhost/backups/n8n"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=30
LOG_FILE="/var/www/selfhost/logs/n8n-backup.log"

# Docker compose file path
COMPOSE_FILE="/var/www/selfhost/docker-compose.https.yml"

# Environment variables
source /var/www/selfhost/.env

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Create backup directories
mkdir -p "$BACKUP_DIR/daily"
mkdir -p "$BACKUP_DIR/weekly" 
mkdir -p "$BACKUP_DIR/monthly"
mkdir -p "$(dirname "$LOG_FILE")"

log "Starting N8N backup process..."

# 1. Export workflows via N8N API (requires API key setup)
log "Exporting workflows via API..."
WORKFLOW_BACKUP_DIR="$BACKUP_DIR/daily/workflows_$TIMESTAMP"
mkdir -p "$WORKFLOW_BACKUP_DIR"

# Note: This requires N8N_API_KEY to be set in .env file
if [ -n "$N8N_API_KEY" ]; then
    # Export all workflows
    curl -H "X-N8N-API-KEY: $N8N_API_KEY" \
         -H "Content-Type: application/json" \
         http://217.154.225.184:5678/api/v1/workflows \
         -o "$WORKFLOW_BACKUP_DIR/workflows.json" 2>/dev/null || log "Warning: API export failed, falling back to file backup"
    
    # Export credentials (encrypted)
    curl -H "X-N8N-API-KEY: $N8N_API_KEY" \
         -H "Content-Type: application/json" \
         http://217.154.225.184:5678/api/v1/credentials \
         -o "$WORKFLOW_BACKUP_DIR/credentials.json" 2>/dev/null || log "Warning: Credentials export failed"
else
    log "Warning: N8N_API_KEY not set, skipping API export"
fi

# 2. Backup N8N storage volume (workflows, settings, credentials)
log "Backing up N8N storage volume..."
docker run --rm \
    -v selfhost_n8n_storage:/n8n-source:ro \
    -v "$BACKUP_DIR/daily":/backup \
    alpine:latest \
    tar -czf "/backup/n8n_storage_$TIMESTAMP.tar.gz" -C /n8n-source .

# 3. Backup N8N binary data volume
log "Backing up N8N binary data..."
docker run --rm \
    -v selfhost_n8n_binary_data:/binary-source:ro \
    -v "$BACKUP_DIR/daily":/backup \
    alpine:latest \
    tar -czf "/backup/n8n_binary_$TIMESTAMP.tar.gz" -C /binary-source .

# 4. Backup PostgreSQL database (N8N workflows and execution data)
log "Backing up PostgreSQL database..."
docker exec selfhost-postgres-1 pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" | \
    gzip > "$BACKUP_DIR/daily/postgres_n8n_$TIMESTAMP.sql.gz"

# 5. Create configuration backup
log "Backing up configuration files..."
CONFIG_BACKUP_DIR="$BACKUP_DIR/daily/config_$TIMESTAMP"
mkdir -p "$CONFIG_BACKUP_DIR"
cp -r /var/www/selfhost/config/n8n/* "$CONFIG_BACKUP_DIR/" 2>/dev/null || true
cp /var/www/selfhost/.env "$CONFIG_BACKUP_DIR/env_backup" 2>/dev/null || true
cp /var/www/selfhost/docker-compose.https.yml "$CONFIG_BACKUP_DIR/" 2>/dev/null || true

# 6. Create manifest file
log "Creating backup manifest..."
cat > "$BACKUP_DIR/daily/manifest_$TIMESTAMP.txt" << EOF
N8N Backup Manifest
Created: $(date)
Timestamp: $TIMESTAMP

Contents:
- workflows_$TIMESTAMP/ (API exports)
- n8n_storage_$TIMESTAMP.tar.gz (N8N application data)
- n8n_binary_$TIMESTAMP.tar.gz (N8N binary files)
- postgres_n8n_$TIMESTAMP.sql.gz (Database dump)
- config_$TIMESTAMP/ (Configuration files)

Docker Volumes:
- selfhost_n8n_storage
- selfhost_n8n_binary_data

Database: $POSTGRES_DB (PostgreSQL)
N8N Version: $(docker exec n8n n8n --version 2>/dev/null || echo "Unknown")
EOF

# 7. Weekly backup (keep weekly backups)
if [ $(date +%u) -eq 7 ]; then  # Sunday
    log "Creating weekly backup..."
    cp -r "$BACKUP_DIR/daily/n8n_storage_$TIMESTAMP.tar.gz" "$BACKUP_DIR/weekly/"
    cp -r "$BACKUP_DIR/daily/postgres_n8n_$TIMESTAMP.sql.gz" "$BACKUP_DIR/weekly/"
fi

# 8. Monthly backup (first day of month)
if [ $(date +%d) -eq 01 ]; then
    log "Creating monthly backup..."
    cp -r "$BACKUP_DIR/daily/n8n_storage_$TIMESTAMP.tar.gz" "$BACKUP_DIR/monthly/"
    cp -r "$BACKUP_DIR/daily/postgres_n8n_$TIMESTAMP.sql.gz" "$BACKUP_DIR/monthly/"
fi

# 9. Cleanup old backups
log "Cleaning up old backups..."
find "$BACKUP_DIR/daily" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR/daily" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR/daily" -type d -name "workflows_*" -mtime +$RETENTION_DAYS -exec rm -rf {} +
find "$BACKUP_DIR/daily" -type d -name "config_*" -mtime +$RETENTION_DAYS -exec rm -rf {} +
find "$BACKUP_DIR/daily" -name "manifest_*.txt" -mtime +$RETENTION_DAYS -delete

# Keep weekly backups for 3 months
find "$BACKUP_DIR/weekly" -name "*.tar.gz" -mtime +90 -delete
find "$BACKUP_DIR/weekly" -name "*.sql.gz" -mtime +90 -delete

# Keep monthly backups for 1 year
find "$BACKUP_DIR/monthly" -name "*.tar.gz" -mtime +365 -delete
find "$BACKUP_DIR/monthly" -name "*.sql.gz" -mtime +365 -delete

# 10. Backup verification
log "Verifying backup integrity..."
BACKUP_SIZE=$(du -sh "$BACKUP_DIR/daily" | cut -f1)
log "Daily backup completed. Size: $BACKUP_SIZE"

# Test tar files
for tar_file in "$BACKUP_DIR/daily"/*.tar.gz; do
    if [ -f "$tar_file" ]; then
        if tar -tzf "$tar_file" >/dev/null 2>&1; then
            log "✓ Verified: $(basename "$tar_file")"
        else
            log "✗ Corrupted: $(basename "$tar_file")"
        fi
    fi
done

# Test SQL dumps
for sql_file in "$BACKUP_DIR/daily"/*.sql.gz; do
    if [ -f "$sql_file" ]; then
        if gunzip -t "$sql_file" 2>/dev/null; then
            log "✓ Verified: $(basename "$sql_file")"
        else
            log "✗ Corrupted: $(basename "$sql_file")"
        fi
    fi
done

log "N8N backup process completed successfully!"
log "Backup location: $BACKUP_DIR/daily"
log "="