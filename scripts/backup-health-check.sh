#!/bin/bash

# Backup Health Check Script
# Überprüft die Integrität und Verfügbarkeit der N8N-Backups
# Author: Claude Code Assistant

set -e

BACKUP_DIR="/var/www/selfhost/backups/n8n"
LOG_FILE="/var/www/selfhost/logs/backup-health-check.log"
EMAIL_ALERT=${EMAIL_ALERT:-false}
ALERT_EMAIL=${ALERT_EMAIL:-"admin@avantera-digital.de"}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    log "${RED}ERROR: $1${NC}"
}

warn() {
    log "${YELLOW}WARNING: $1${NC}"
}

success() {
    log "${GREEN}SUCCESS: $1${NC}"
}

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

log "Starting backup health check..."

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    error "Backup directory not found: $BACKUP_DIR"
    exit 1
fi

# Check recent backups (last 3 days)
RECENT_BACKUPS=0
CORRUPTED_BACKUPS=0
TOTAL_SIZE=0

log "Checking recent backups (last 3 days)..."

# Find recent manifest files
find "$BACKUP_DIR/daily" -name "manifest_*.txt" -mtime -3 2>/dev/null | while read manifest; do
    if [ -f "$manifest" ]; then
        timestamp=$(basename "$manifest" | sed 's/manifest_//;s/.txt//')
        log "Checking backup: $timestamp"
        
        # Check storage backup
        storage_backup="$BACKUP_DIR/daily/n8n_storage_$timestamp.tar.gz"
        if [ -f "$storage_backup" ]; then
            if tar -tzf "$storage_backup" >/dev/null 2>&1; then
                success "Storage backup OK: $timestamp"
                RECENT_BACKUPS=$((RECENT_BACKUPS + 1))
            else
                error "Storage backup corrupted: $timestamp"
                CORRUPTED_BACKUPS=$((CORRUPTED_BACKUPS + 1))
            fi
            
            # Add to total size
            size=$(stat -f%z "$storage_backup" 2>/dev/null || stat -c%s "$storage_backup" 2>/dev/null || echo 0)
            TOTAL_SIZE=$((TOTAL_SIZE + size))
        else
            warn "Storage backup missing: $timestamp"
        fi
        
        # Check database backup
        db_backup="$BACKUP_DIR/daily/postgres_n8n_$timestamp.sql.gz"
        if [ -f "$db_backup" ]; then
            if gunzip -t "$db_backup" 2>/dev/null; then
                success "Database backup OK: $timestamp"
            else
                error "Database backup corrupted: $timestamp"
                CORRUPTED_BACKUPS=$((CORRUPTED_BACKUPS + 1))
            fi
        else
            warn "Database backup missing: $timestamp"
        fi
    fi
done

# Check disk space
BACKUP_SIZE_GB=$((TOTAL_SIZE / 1024 / 1024 / 1024))
AVAILABLE_SPACE=$(df -BG "$BACKUP_DIR" | awk 'NR==2 {print $4}' | sed 's/G//')

log "Backup statistics:"
log "- Recent backups found: $RECENT_BACKUPS"
log "- Corrupted backups: $CORRUPTED_BACKUPS"
log "- Total backup size: ${BACKUP_SIZE_GB}GB"
log "- Available space: ${AVAILABLE_SPACE}GB"

# Check if last backup is recent (within 25 hours)
LAST_BACKUP=$(find "$BACKUP_DIR/daily" -name "manifest_*.txt" -mtime -1 | head -1)
if [ -n "$LAST_BACKUP" ]; then
    success "Recent backup found (within 24h)"
else
    error "No backup found within last 24 hours!"
    if [ "$EMAIL_ALERT" = "true" ]; then
        echo "N8N Backup Alert: No recent backup found!" | mail -s "Backup Alert" "$ALERT_EMAIL" 2>/dev/null || true
    fi
fi

# Check N8N service status
if docker compose -f /var/www/selfhost/docker-compose.https.yml ps n8n | grep -q "Up"; then
    success "N8N service is running"
else
    warn "N8N service is not running"
fi

# Check if N8N is accessible
if curl -sf http://217.154.225.184:5678/healthz >/dev/null 2>&1; then
    success "N8N API is accessible"
else
    warn "N8N API is not accessible"
fi

# Cleanup old health check logs (keep 30 days)
find "$(dirname "$LOG_FILE")" -name "backup-health-check.log*" -mtime +30 -delete 2>/dev/null || true

# Summary
if [ $CORRUPTED_BACKUPS -eq 0 ] && [ $RECENT_BACKUPS -gt 0 ]; then
    success "All backup health checks passed!"
    exit 0
else
    error "Backup health check issues found!"
    if [ "$EMAIL_ALERT" = "true" ]; then
        echo "N8N Backup Health Check Failed - $CORRUPTED_BACKUPS corrupted backups found" | \
            mail -s "Backup Health Alert" "$ALERT_EMAIL" 2>/dev/null || true
    fi
    exit 1
fi