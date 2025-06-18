#!/bin/bash

# N8N Disaster Recovery & Restore Script
# Stellt N8N Workflows, Credentials und Datenbank aus Backups wieder her
# Author: Claude Code Assistant
# Version: 1.0

set -e

# Configuration
BACKUP_DIR="/var/www/selfhost/backups/n8n"
LOG_FILE="/var/www/selfhost/logs/n8n-restore.log"
COMPOSE_FILE="/var/www/selfhost/docker-compose.https.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "${RED}ERROR: $1${NC}"
    exit 1
}

# Warning function
warn() {
    log "${YELLOW}WARNING: $1${NC}"
}

# Success function
success() {
    log "${GREEN}SUCCESS: $1${NC}"
}

# Show usage
usage() {
    echo "N8N Disaster Recovery Script"
    echo ""
    echo "Usage: $0 [OPTION] [BACKUP_TIMESTAMP]"
    echo ""
    echo "Options:"
    echo "  -l, --list          List available backups"
    echo "  -r, --restore       Restore from backup (requires timestamp)"
    echo "  -f, --full          Full disaster recovery (complete restore)"
    echo "  -w, --workflows     Restore only workflows"
    echo "  -d, --database      Restore only database"
    echo "  -c, --config        Restore only configuration"
    echo "  -v, --verify        Verify backup integrity"
    echo "  -h, --help          Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --list"
    echo "  $0 --restore 20240618_120000"
    echo "  $0 --full 20240618_120000"
    echo "  $0 --workflows 20240618_120000"
    echo ""
}

# List available backups
list_backups() {
    log "Available N8N backups:"
    echo ""
    
    if [ -d "$BACKUP_DIR/daily" ]; then
        echo "=== DAILY BACKUPS ==="
        ls -la "$BACKUP_DIR/daily/manifest_"*.txt 2>/dev/null | while read line; do
            manifest_file=$(echo $line | awk '{print $9}')
            if [ -f "$manifest_file" ]; then
                timestamp=$(basename "$manifest_file" | sed 's/manifest_//;s/.txt//')
                size=$(du -sh "$(dirname "$manifest_file")" | cut -f1)
                echo "Timestamp: $timestamp (Size: $size)"
                head -n 5 "$manifest_file" | tail -n 3
                echo ""
            fi
        done
    fi
    
    if [ -d "$BACKUP_DIR/weekly" ]; then
        echo "=== WEEKLY BACKUPS ==="
        ls "$BACKUP_DIR/weekly/"*.tar.gz 2>/dev/null | head -5
        echo ""
    fi
    
    if [ -d "$BACKUP_DIR/monthly" ]; then
        echo "=== MONTHLY BACKUPS ==="
        ls "$BACKUP_DIR/monthly/"*.tar.gz 2>/dev/null | head -5
        echo ""
    fi
}

# Verify backup integrity
verify_backup() {
    local timestamp=$1
    log "Verifying backup integrity for timestamp: $timestamp"
    
    local backup_path="$BACKUP_DIR/daily"
    local errors=0
    
    # Check manifest
    if [ ! -f "$backup_path/manifest_$timestamp.txt" ]; then
        error_exit "Manifest file not found for timestamp $timestamp"
    fi
    
    # Verify storage backup
    if [ -f "$backup_path/n8n_storage_$timestamp.tar.gz" ]; then
        if tar -tzf "$backup_path/n8n_storage_$timestamp.tar.gz" >/dev/null 2>&1; then
            success "N8N storage backup verified"
        else
            warn "N8N storage backup corrupted"
            ((errors++))
        fi
    fi
    
    # Verify binary backup
    if [ -f "$backup_path/n8n_binary_$timestamp.tar.gz" ]; then
        if tar -tzf "$backup_path/n8n_binary_$timestamp.tar.gz" >/dev/null 2>&1; then
            success "N8N binary backup verified"
        else
            warn "N8N binary backup corrupted"
            ((errors++))
        fi
    fi
    
    # Verify database backup
    if [ -f "$backup_path/postgres_n8n_$timestamp.sql.gz" ]; then
        if gunzip -t "$backup_path/postgres_n8n_$timestamp.sql.gz" 2>/dev/null; then
            success "PostgreSQL backup verified"
        else
            warn "PostgreSQL backup corrupted"
            ((errors++))
        fi
    fi
    
    if [ $errors -eq 0 ]; then
        success "All backup files verified successfully"
        return 0
    else
        warn "$errors backup files have issues"
        return 1
    fi
}

# Stop N8N services
stop_n8n() {
    log "Stopping N8N services..."
    docker compose -f "$COMPOSE_FILE" stop n8n || true
    success "N8N services stopped"
}

# Start N8N services
start_n8n() {
    log "Starting N8N services..."
    docker compose -f "$COMPOSE_FILE" up -d n8n
    
    # Wait for N8N to be ready
    log "Waiting for N8N to start..."
    for i in {1..30}; do
        if curl -sf http://217.154.225.184:5678/healthz >/dev/null 2>&1; then
            success "N8N is ready"
            return 0
        fi
        sleep 5
    done
    
    warn "N8N may not be fully ready yet"
}

# Restore workflows only
restore_workflows() {
    local timestamp=$1
    log "Restoring workflows for timestamp: $timestamp"
    
    # Restore storage volume
    if [ -f "$BACKUP_DIR/daily/n8n_storage_$timestamp.tar.gz" ]; then
        stop_n8n
        
        docker run --rm \
            -v selfhost_n8n_storage:/n8n-target \
            -v "$BACKUP_DIR/daily":/backup:ro \
            alpine:latest \
            sh -c "rm -rf /n8n-target/* && tar -xzf /backup/n8n_storage_$timestamp.tar.gz -C /n8n-target"
        
        start_n8n
        success "Workflows restored successfully"
    else
        error_exit "Storage backup not found for timestamp $timestamp"
    fi
}

# Restore database only
restore_database() {
    local timestamp=$1
    log "Restoring database for timestamp: $timestamp"
    
    if [ -f "$BACKUP_DIR/daily/postgres_n8n_$timestamp.sql.gz" ]; then
        # Source environment variables
        source /var/www/selfhost/.env
        
        # Stop N8N to prevent conflicts
        stop_n8n
        
        # Drop and recreate database
        docker exec selfhost-postgres-1 psql -U "$POSTGRES_USER" -c "DROP DATABASE IF EXISTS ${POSTGRES_DB}_restore;"
        docker exec selfhost-postgres-1 psql -U "$POSTGRES_USER" -c "CREATE DATABASE ${POSTGRES_DB}_restore;"
        
        # Restore from backup
        gunzip -c "$BACKUP_DIR/daily/postgres_n8n_$timestamp.sql.gz" | \
            docker exec -i selfhost-postgres-1 psql -U "$POSTGRES_USER" -d "${POSTGRES_DB}_restore"
        
        # Switch databases
        docker exec selfhost-postgres-1 psql -U "$POSTGRES_USER" -c "DROP DATABASE IF EXISTS ${POSTGRES_DB}_old;"
        docker exec selfhost-postgres-1 psql -U "$POSTGRES_USER" -c "ALTER DATABASE $POSTGRES_DB RENAME TO ${POSTGRES_DB}_old;"
        docker exec selfhost-postgres-1 psql -U "$POSTGRES_USER" -c "ALTER DATABASE ${POSTGRES_DB}_restore RENAME TO $POSTGRES_DB;"
        
        start_n8n
        success "Database restored successfully"
    else
        error_exit "Database backup not found for timestamp $timestamp"
    fi
}

# Full disaster recovery
full_restore() {
    local timestamp=$1
    log "Starting full disaster recovery for timestamp: $timestamp"
    
    # Verify backup first
    if ! verify_backup "$timestamp"; then
        error_exit "Backup verification failed"
    fi
    
    # Stop services
    stop_n8n
    
    # Restore storage
    log "Restoring N8N storage..."
    docker run --rm \
        -v selfhost_n8n_storage:/n8n-target \
        -v "$BACKUP_DIR/daily":/backup:ro \
        alpine:latest \
        sh -c "rm -rf /n8n-target/* && tar -xzf /backup/n8n_storage_$timestamp.tar.gz -C /n8n-target"
    
    # Restore binary data
    log "Restoring N8N binary data..."
    docker run --rm \
        -v selfhost_n8n_binary_data:/binary-target \
        -v "$BACKUP_DIR/daily":/backup:ro \
        alpine:latest \
        sh -c "rm -rf /binary-target/* && tar -xzf /backup/n8n_binary_$timestamp.tar.gz -C /binary-target"
    
    # Restore database
    restore_database "$timestamp"
    
    # Restore configuration if available
    if [ -d "$BACKUP_DIR/daily/config_$timestamp" ]; then
        log "Restoring configuration..."
        cp -r "$BACKUP_DIR/daily/config_$timestamp"/* /var/www/selfhost/config/n8n/ 2>/dev/null || true
    fi
    
    success "Full disaster recovery completed successfully!"
    log "Please verify that all workflows and credentials are working correctly"
}

# Main script logic
case "${1:-}" in
    -l|--list)
        list_backups
        ;;
    -r|--restore)
        if [ -z "${2:-}" ]; then
            error_exit "Timestamp required for restore. Use --list to see available backups."
        fi
        restore_workflows "$2"
        ;;
    -f|--full)
        if [ -z "${2:-}" ]; then
            error_exit "Timestamp required for full restore. Use --list to see available backups."
        fi
        echo "WARNING: This will completely restore N8N from backup!"
        echo "This will overwrite all current workflows, credentials, and data."
        echo -n "Are you sure? (yes/no): "
        read confirmation
        if [ "$confirmation" = "yes" ]; then
            full_restore "$2"
        else
            log "Restore cancelled by user"
        fi
        ;;
    -w|--workflows)
        if [ -z "${2:-}" ]; then
            error_exit "Timestamp required for workflow restore. Use --list to see available backups."
        fi
        restore_workflows "$2"
        ;;
    -d|--database)
        if [ -z "${2:-}" ]; then
            error_exit "Timestamp required for database restore. Use --list to see available backups."
        fi
        restore_database "$2"
        ;;
    -v|--verify)
        if [ -z "${2:-}" ]; then
            error_exit "Timestamp required for verification. Use --list to see available backups."
        fi
        verify_backup "$2"
        ;;
    -h|--help)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac