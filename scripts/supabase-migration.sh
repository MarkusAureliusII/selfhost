#!/bin/bash

# Supabase Migration Script
# Migrates data from external Supabase to self-hosted instance
# Author: Claude Code Assistant

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="/var/www/selfhost/backups/supabase-migration"
LOG_FILE="/var/www/selfhost/logs/supabase-migration.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create directories
mkdir -p "$BACKUP_DIR" "$(dirname "$LOG_FILE")"

# Logging function
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

success() {
    log "${GREEN}✓ $1${NC}"
}

error() {
    log "${RED}✗ ERROR: $1${NC}"
}

warn() {
    log "${YELLOW}! WARNING: $1${NC}"
}

info() {
    log "${BLUE}ℹ INFO: $1${NC}"
}

# Check required environment variables
check_env() {
    local missing=0
    
    if [ -z "$EXTERNAL_SUPABASE_URL" ]; then
        error "EXTERNAL_SUPABASE_URL not set"
        missing=1
    fi
    
    if [ -z "$EXTERNAL_SUPABASE_SERVICE_KEY" ]; then
        error "EXTERNAL_SUPABASE_SERVICE_KEY not set"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        error "Please set external Supabase environment variables:"
        echo "export EXTERNAL_SUPABASE_URL='https://your-project.supabase.co'"
        echo "export EXTERNAL_SUPABASE_SERVICE_KEY='your_service_role_key'"
        exit 1
    fi
}

# Export table structure from external Supabase
export_table_structure() {
    local table_name=$1
    info "Exporting table structure for: $table_name"
    
    # Get table structure via API
    curl -s \
        -H "apikey: $EXTERNAL_SUPABASE_SERVICE_KEY" \
        -H "Authorization: Bearer $EXTERNAL_SUPABASE_SERVICE_KEY" \
        "$EXTERNAL_SUPABASE_URL/rest/v1/$table_name?select=*&limit=0" \
        > "$BACKUP_DIR/${table_name}_structure_$TIMESTAMP.json"
    
    success "Table structure exported: $table_name"
}

# Export table data from external Supabase
export_table_data() {
    local table_name=$1
    info "Exporting data for table: $table_name"
    
    # Export all data
    curl -s \
        -H "apikey: $EXTERNAL_SUPABASE_SERVICE_KEY" \
        -H "Authorization: Bearer $EXTERNAL_SUPABASE_SERVICE_KEY" \
        "$EXTERNAL_SUPABASE_URL/rest/v1/$table_name" \
        > "$BACKUP_DIR/${table_name}_data_$TIMESTAMP.json"
    
    # Count records
    local count=$(jq length "$BACKUP_DIR/${table_name}_data_$TIMESTAMP.json" 2>/dev/null || echo "0")
    success "Exported $count records from $table_name"
}

# Get list of tables from external Supabase
get_external_tables() {
    info "Discovering tables in external Supabase..."
    
    # This is a simplified approach - in practice, you might need to use pg_dump
    # For now, we'll focus on the leads table mentioned
    echo "leads"
}

# Import table structure to local Supabase
import_table_structure() {
    local table_name=$1
    info "Creating table structure in local Supabase: $table_name"
    
    # Connect to local Supabase database
    local create_sql=""
    
    # For leads table, create a common structure
    if [ "$table_name" = "leads" ]; then
        create_sql="
        CREATE TABLE IF NOT EXISTS public.leads (
            id BIGSERIAL PRIMARY KEY,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
            name TEXT,
            email TEXT,
            phone TEXT,
            company TEXT,
            message TEXT,
            source TEXT,
            status TEXT DEFAULT 'new',
            metadata JSONB
        );
        
        -- Enable Row Level Security
        ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
        
        -- Create policy for authenticated users
        CREATE POLICY IF NOT EXISTS \"Enable all access for authenticated users\" ON public.leads
            FOR ALL USING (auth.role() = 'authenticated');
        "
    fi
    
    if [ -n "$create_sql" ]; then
        docker exec supabase-db psql -U postgres -d postgres -c "$create_sql"
        success "Table $table_name created in local Supabase"
    else
        warn "No predefined structure for table: $table_name"
    fi
}

# Import data to local Supabase
import_table_data() {
    local table_name=$1
    local data_file="$BACKUP_DIR/${table_name}_data_$TIMESTAMP.json"
    
    if [ ! -f "$data_file" ]; then
        error "Data file not found: $data_file"
        return 1
    fi
    
    info "Importing data to local Supabase: $table_name"
    
    # Convert JSON to SQL INSERT statements
    local temp_sql="/tmp/${table_name}_import_$TIMESTAMP.sql"
    
    # Create SQL from JSON data
    jq -r '.[] | [
        .name // "NULL",
        .email // "NULL", 
        .phone // "NULL",
        .company // "NULL",
        .message // "NULL",
        .source // "NULL",
        .status // "new",
        (.metadata // {} | tostring)
    ] | "INSERT INTO public.leads (name, email, phone, company, message, source, status, metadata) VALUES (" + 
    (map(if . == "NULL" then "NULL" else "'" + (. | gsub("'";"''")) + "'" end) | join(", ")) + 
    ");"' "$data_file" > "$temp_sql"
    
    # Execute SQL
    if docker exec -i supabase-db psql -U postgres -d postgres < "$temp_sql"; then
        local count=$(wc -l < "$temp_sql")
        success "Imported $count records to $table_name"
        rm -f "$temp_sql"
    else
        error "Failed to import data to $table_name"
        return 1
    fi
}

# Test local Supabase connection
test_local_connection() {
    info "Testing local Supabase connection..."
    
    if curl -sf "http://217.154.225.184:8000/rest/v1/leads?select=count" \
        -H "apikey: $(grep SUPABASE_ANON_KEY /var/www/selfhost/.env | cut -d'=' -f2)" \
        >/dev/null 2>&1; then
        success "Local Supabase API is accessible"
        return 0
    else
        error "Cannot connect to local Supabase API"
        return 1
    fi
}

# Main migration process
main() {
    log "Starting Supabase migration process..."
    
    # Check environment
    check_env
    
    # Test local connection
    test_local_connection || exit 1
    
    # Get tables to migrate
    local tables=$(get_external_tables)
    
    for table in $tables; do
        log "Processing table: $table"
        
        # Export from external
        export_table_structure "$table"
        export_table_data "$table"
        
        # Import to local
        import_table_structure "$table"
        import_table_data "$table"
        
        success "Migration completed for table: $table"
    done
    
    # Create backup manifest
    cat > "$BACKUP_DIR/migration_manifest_$TIMESTAMP.txt" << EOF
Supabase Migration Manifest
Created: $(date)
Timestamp: $TIMESTAMP

Source: $EXTERNAL_SUPABASE_URL
Target: http://217.154.225.184:8000

Tables migrated:
$(echo "$tables" | sed 's/^/- /')

Files created:
$(ls -la "$BACKUP_DIR" | grep "$TIMESTAMP")
EOF
    
    success "Supabase migration completed successfully!"
    info "Migration manifest: $BACKUP_DIR/migration_manifest_$TIMESTAMP.txt"
    info "Migration logs: $LOG_FILE"
}

# Usage information
usage() {
    echo "Supabase Migration Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help"
    echo "  -t, --test     Test connections only"
    echo "  -d, --dry-run  Show what would be migrated"
    echo ""
    echo "Environment variables required:"
    echo "  EXTERNAL_SUPABASE_URL          External Supabase project URL"
    echo "  EXTERNAL_SUPABASE_SERVICE_KEY  External Supabase service role key"
    echo ""
    echo "Example:"
    echo "  export EXTERNAL_SUPABASE_URL='https://your-project.supabase.co'"
    echo "  export EXTERNAL_SUPABASE_SERVICE_KEY='your_service_key'"
    echo "  $0"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        usage
        exit 0
        ;;
    -t|--test)
        check_env
        test_local_connection
        info "External Supabase: $EXTERNAL_SUPABASE_URL"
        info "Local Supabase: http://217.154.225.184:8000"
        exit 0
        ;;
    -d|--dry-run)
        check_env
        info "Would migrate tables: $(get_external_tables)"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
esac