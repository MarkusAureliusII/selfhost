#!/bin/bash

# Simple Leads Import Script
# Imports leads data from external Supabase to local instance
# Usage: ./import-leads.sh <external_supabase_url> <external_service_key>

set -e

EXTERNAL_URL="$1"
EXTERNAL_KEY="$2"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/var/www/selfhost/backups/supabase-migration"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$EXTERNAL_URL" ] || [ -z "$EXTERNAL_KEY" ]; then
    echo -e "${RED}Usage: $0 <external_supabase_url> <external_service_key>${NC}"
    echo ""
    echo "Example:"
    echo "  $0 'https://your-project.supabase.co' 'your_service_role_key'"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

echo -e "${YELLOW}🔄 Starting leads migration...${NC}"

# 1. Export leads from external Supabase
echo -e "${YELLOW}📤 Exporting leads from external Supabase...${NC}"
curl -s \
    -H "apikey: $EXTERNAL_KEY" \
    -H "Authorization: Bearer $EXTERNAL_KEY" \
    -H "Content-Type: application/json" \
    "$EXTERNAL_URL/rest/v1/leads" \
    > "$BACKUP_DIR/leads_export_$TIMESTAMP.json"

# Check if export was successful
if [ $? -eq 0 ] && [ -s "$BACKUP_DIR/leads_export_$TIMESTAMP.json" ]; then
    RECORD_COUNT=$(jq length "$BACKUP_DIR/leads_export_$TIMESTAMP.json" 2>/dev/null || echo "0")
    echo -e "${GREEN}✅ Exported $RECORD_COUNT leads${NC}"
else
    echo -e "${RED}❌ Failed to export leads${NC}"
    exit 1
fi

# 2. Transform and import to local Supabase
echo -e "${YELLOW}📥 Importing leads to local Supabase...${NC}"

# Local Supabase credentials
LOCAL_URL="http://217.154.225.184:8000"
LOCAL_KEY="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpLXN0YWNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg2MDIwMCwiZXhwIjoxODQyNjQ2NjAwfQ.pJ7qQ4RvM5L8nGx3Hp9s6kF2J9vF3nHdY1kF4M-8Wy"

# Import each record
jq -c '.[]' "$BACKUP_DIR/leads_export_$TIMESTAMP.json" | while read -r lead; do
    # Remove id field to let local DB generate new IDs
    cleaned_lead=$(echo "$lead" | jq 'del(.id)')
    
    # Import to local Supabase
    response=$(curl -s -w "%{http_code}" \
        -X POST \
        -H "apikey: $LOCAL_KEY" \
        -H "Authorization: Bearer $LOCAL_KEY" \
        -H "Content-Type: application/json" \
        -H "Prefer: return=minimal" \
        -d "$cleaned_lead" \
        "$LOCAL_URL/rest/v1/leads")
    
    http_code="${response: -3}"
    if [ "$http_code" = "201" ]; then
        echo -n "."
    else
        echo -e "\n${RED}Failed to import lead: HTTP $http_code${NC}"
    fi
done

echo ""

# 3. Verify import
echo -e "${YELLOW}🔍 Verifying import...${NC}"
local_count=$(curl -s \
    -H "apikey: $LOCAL_KEY" \
    -H "Authorization: Bearer $LOCAL_KEY" \
    "$LOCAL_URL/rest/v1/leads?select=count" | jq -r '.[0].count' 2>/dev/null || echo "0")

echo -e "${GREEN}✅ Migration completed!${NC}"
echo -e "${GREEN}📊 Records in local Supabase: $local_count${NC}"
echo -e "${GREEN}💾 Export backup saved: $BACKUP_DIR/leads_export_$TIMESTAMP.json${NC}"

# 4. Test local Supabase access
echo -e "${YELLOW}🧪 Testing local Supabase access...${NC}"
test_response=$(curl -s \
    -H "apikey: $LOCAL_KEY" \
    -H "Authorization: Bearer $LOCAL_KEY" \
    "$LOCAL_URL/rest/v1/leads?limit=1")

if echo "$test_response" | jq . >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Local Supabase API is working correctly${NC}"
    echo -e "${GREEN}🎉 Migration successful! Your N8N can now access leads at:${NC}"
    echo -e "${GREEN}   URL: $LOCAL_URL/rest/v1/leads${NC}"
    echo -e "${GREEN}   API Key: $LOCAL_KEY${NC}"
else
    echo -e "${RED}❌ Local Supabase API test failed${NC}"
fi