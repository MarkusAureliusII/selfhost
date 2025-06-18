#!/bin/bash

# Supabase Schema Discovery Script
# Discovers all tables, views, and policies from external Supabase

set -e

EXTERNAL_URL="https://qkzikqgypwliucfdmcbj.supabase.co"
EXTERNAL_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFremlrcWd5cHdsaXVjZmRtY2JqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0OTkzMzExOSwiZXhwIjoyMDY1NTA5MTE5fQ.8GPERKrJioblxbgWer3lCtYkIcLJEa2f4zFwU_tPtsM"
BACKUP_DIR="/var/www/selfhost/backups/supabase-schema"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

mkdir -p "$BACKUP_DIR"

echo "🔍 Discovering Supabase schema..."

# Common table names to check
COMMON_TABLES=(
    "leads"
    "users" 
    "profiles"
    "auth.users"
    "contacts"
    "companies"
    "projects"
    "tasks"
    "notes"
    "activities"
    "campaigns"
    "emails"
    "webhooks"
    "integrations"
    "settings"
    "teams"
    "workspaces"
    "api_keys"
    "logs"
    "events"
    "notifications"
    "files"
    "documents"
    "tags"
    "categories"
    "custom_fields"
    "workflows"
    "automations"
    "reports"
    "analytics"
)

echo "📊 Checking for existing tables..."

# Check each table
for table in "${COMMON_TABLES[@]}"; do
    echo -n "Checking $table... "
    
    response=$(curl -s -w "%{http_code}" \
        -H "apikey: $EXTERNAL_KEY" \
        -H "Authorization: Bearer $EXTERNAL_KEY" \
        "$EXTERNAL_URL/rest/v1/$table?limit=0" 2>/dev/null)
    
    http_code="${response: -3}"
    response_body="${response%???}"
    
    if [ "$http_code" = "200" ]; then
        echo "✅ EXISTS"
        echo "$table" >> "$BACKUP_DIR/existing_tables_$TIMESTAMP.txt"
        
        # Get table structure by fetching with limit 1
        curl -s \
            -H "apikey: $EXTERNAL_KEY" \
            -H "Authorization: Bearer $EXTERNAL_KEY" \
            "$EXTERNAL_URL/rest/v1/$table?limit=1" \
            > "$BACKUP_DIR/${table}_sample_$TIMESTAMP.json"
        
        # Get row count
        count_response=$(curl -s \
            -H "apikey: $EXTERNAL_KEY" \
            -H "Authorization: Bearer $EXTERNAL_KEY" \
            -H "Prefer: count=exact" \
            "$EXTERNAL_URL/rest/v1/$table?select=*&limit=0")
        
        # Extract count from Content-Range header would be better, but this works
        echo "  Table: $table (checking row count...)" >> "$BACKUP_DIR/table_info_$TIMESTAMP.txt"
        
    elif [ "$http_code" = "404" ]; then
        echo "❌ NOT FOUND"
    elif [ "$http_code" = "401" ] || [ "$http_code" = "403" ]; then
        echo "🔒 ACCESS DENIED"
    else
        echo "⚠️  HTTP $http_code"
    fi
done

echo ""
echo "📋 Found tables:"
if [ -f "$BACKUP_DIR/existing_tables_$TIMESTAMP.txt" ]; then
    cat "$BACKUP_DIR/existing_tables_$TIMESTAMP.txt"
    
    # Get detailed info for each existing table
    while read -r table; do
        echo "📊 Getting detailed info for $table..."
        
        # Export full data
        curl -s \
            -H "apikey: $EXTERNAL_KEY" \
            -H "Authorization: Bearer $EXTERNAL_KEY" \
            "$EXTERNAL_URL/rest/v1/$table" \
            > "$BACKUP_DIR/${table}_data_$TIMESTAMP.json"
        
        # Count records
        count=$(jq length "$BACKUP_DIR/${table}_data_$TIMESTAMP.json" 2>/dev/null || echo "0")
        echo "  $table: $count records"
        
    done < "$BACKUP_DIR/existing_tables_$TIMESTAMP.txt"
else
    echo "No additional tables found beyond 'leads'"
fi

echo ""
echo "✅ Schema discovery complete!"
echo "📁 Files saved to: $BACKUP_DIR/"
echo ""
echo "Found tables:"
ls -la "$BACKUP_DIR/"*_tables_*.txt 2>/dev/null | head -5
echo ""
echo "Data exports:"
ls -la "$BACKUP_DIR/"*_data_*.json 2>/dev/null | head -10