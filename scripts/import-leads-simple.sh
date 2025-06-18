#!/bin/bash

# Simple Leads Import - Direct Database Import
# Imports the exact schema structure

set -e

EXTERNAL_URL="https://qkzikqgypwliucfdmcbj.supabase.co"
EXTERNAL_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFremlrcWd5cHdsaXVjZmRtY2JqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0OTkzMzExOSwiZXhwIjoyMDY1NTA5MTE5fQ.8GPERKrJioblxbgWer3lCtYkIcLJEa2f4zFwU_tPtsM"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/var/www/selfhost/backups/supabase-migration"

mkdir -p "$BACKUP_DIR"

echo "🔄 Exporting leads from external Supabase..."

# Export leads data
curl -s \
    -H "apikey: $EXTERNAL_KEY" \
    -H "Authorization: Bearer $EXTERNAL_KEY" \
    "$EXTERNAL_URL/rest/v1/leads" \
    > "$BACKUP_DIR/leads_full_$TIMESTAMP.json"

RECORD_COUNT=$(jq length "$BACKUP_DIR/leads_full_$TIMESTAMP.json")
echo "✅ Exported $RECORD_COUNT leads"

echo "📥 Importing to local database..."

# Convert JSON to SQL INSERT
jq -r '.[] | 
    "INSERT INTO public.leads (
        source_id, created_at, updated_at, first_name, last_name, title, email, phone, 
        country, city, state, company_name, person_linkedin_url, company_linkedin_url, 
        facebook_url, keywords, raw_scraped_data, enriched_data, scrape_job_id, user_id, 
        website, is_personal_linkedin_analyzed, is_email_verified, is_company_linkedin_analyzed, 
        is_website_analyzed, is_custom_field_1_analyzed, phone_number, analysis_text_personal_linkedin, 
        analysis_text_company_linkedin, analysis_text_website, email_verification_status, 
        is_email_verification_processed, actor_run_id
    ) VALUES (" +
    [
        (.source_id // "NULL"),
        (.created_at // "NULL"),
        (.updated_at // "NULL"),
        (.first_name // "NULL"),
        (.last_name // "NULL"),
        (.title // "NULL"),
        (.email // "NULL"),
        (.phone // "NULL"),
        (.country // "NULL"),
        (.city // "NULL"),
        (.state // "NULL"),
        (.company_name // "NULL"),
        (.person_linkedin_url // "NULL"),
        (.company_linkedin_url // "NULL"),
        (.facebook_url // "NULL"),
        (if .keywords then .keywords | @json else "NULL" end),
        (if .raw_scraped_data then .raw_scraped_data | @json else "NULL" end),
        (if .enriched_data then .enriched_data | @json else "NULL" end),
        (.scrape_job_id // "NULL"),
        (.user_id // "NULL"),
        (.website // "NULL"),
        (.is_personal_linkedin_analyzed // false),
        (.is_email_verified // false),
        (.is_company_linkedin_analyzed // false),
        (.is_website_analyzed // false),
        (.is_custom_field_1_analyzed // false),
        (.phone_number // "NULL"),
        (.analysis_text_personal_linkedin // "NULL"),
        (.analysis_text_company_linkedin // "NULL"),
        (.analysis_text_website // "NULL"),
        (.email_verification_status // "NULL"),
        (.is_email_verification_processed // false),
        (.actor_run_id // "NULL")
    ] | map(
        if . == "NULL" then "NULL" 
        elif type == "boolean" then tostring
        else "'" + (tostring | gsub("'";"''")) + "'" 
        end
    ) | join(", ") + ");"' \
    "$BACKUP_DIR/leads_full_$TIMESTAMP.json" > "/tmp/leads_import_$TIMESTAMP.sql"

# Import to database
echo "💾 Executing SQL import..."
docker exec -i -e PGPASSWORD=supabase_secure_db_2024 supabase-db psql -U postgres -d postgres < "/tmp/leads_import_$TIMESTAMP.sql"

# Verify import
FINAL_COUNT=$(docker exec -e PGPASSWORD=supabase_secure_db_2024 supabase-db psql -U postgres -d postgres -t -c "SELECT COUNT(*) FROM public.leads;")

echo "✅ Import completed!"
echo "📊 Records imported: $FINAL_COUNT"

# Clean up
rm -f "/tmp/leads_import_$TIMESTAMP.sql"

echo "🎉 Your leads are now available in local Supabase!"
echo "API URL: http://217.154.225.184:8000/rest/v1/leads"