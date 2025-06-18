# N8N → Local Supabase Connection Guide

## ✅ Migration Complete!

**Your external Supabase leads have been successfully imported to your self-hosted instance.**

- **Total Leads Migrated**: 546 leads
- **Database**: PostgreSQL running in `supabase-db` container
- **API Access**: Via direct database connection (Kong API having issues)

## N8N Configuration Options

### Option 1: Direct Database Connection (Recommended)

Use the **PostgreSQL node** in N8N to connect directly to your local database:

**Connection Details:**
```
Host: supabase-db (internal Docker network)
Port: 5432
Database: postgres
Username: postgres
Password: supabase_secure_db_2024
```

**Example Query to Get All Leads:**
```sql
SELECT 
    first_name, 
    last_name, 
    email, 
    company_name, 
    title, 
    phone, 
    city, 
    country,
    created_at
FROM public.leads
ORDER BY created_at DESC;
```

**Example Query to Get New Leads (Last 24h):**
```sql
SELECT * FROM public.leads 
WHERE created_at >= NOW() - INTERVAL '1 DAY'
ORDER BY created_at DESC;
```

### Option 2: HTTP Request Node (Alternative)

If you prefer REST API calls, use the **HTTP Request node**:

**URL**: `http://supabase-db:5432` (direct database access)
*Note: The Kong API gateway is currently having plugin issues*

## N8N Workflow Examples

### 1. Daily Lead Report Workflow

**Trigger**: Schedule (daily at 9 AM)
**Node 1**: PostgreSQL Query
```sql
SELECT 
    COUNT(*) as total_leads,
    COUNT(CASE WHEN created_at >= CURRENT_DATE THEN 1 END) as new_today
FROM public.leads;
```
**Node 2**: Send Email/Slack notification

### 2. Lead Processing Workflow

**Trigger**: Manual/Webhook
**Node 1**: Get leads by status
```sql
SELECT * FROM public.leads 
WHERE email IS NOT NULL 
  AND email != ''
  AND is_email_verified = false
LIMIT 10;
```
**Node 2**: Process leads (email validation, enrichment, etc.)

### 3. Lead Export Workflow

**Trigger**: Manual
**Node 1**: Export to CSV
```sql
SELECT 
    first_name,
    last_name,
    email,
    company_name,
    title,
    phone,
    city,
    country,
    created_at
FROM public.leads
ORDER BY created_at DESC;
```

## Database Schema

Your leads table structure:
```sql
CREATE TABLE public.leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    first_name TEXT,
    last_name TEXT,
    title TEXT,
    email TEXT,
    phone TEXT,
    country TEXT,
    city TEXT,
    state TEXT,
    company_name TEXT,
    person_linkedin_url TEXT,
    company_linkedin_url TEXT,
    website TEXT,
    -- ... other fields
);
```

## Testing Your Setup

### 1. Test Database Connection

Go to N8N → Credentials → Create New → PostgreSQL:
- **Host**: `supabase-db`
- **Port**: `5432`
- **Database**: `postgres`
- **User**: `postgres`
- **Password**: `supabase_secure_db_2024`

### 2. Test Query

Create a simple workflow:
1. **Manual Trigger**
2. **PostgreSQL Node** with query: `SELECT COUNT(*) FROM public.leads;`
3. Should return: `{"count": 546}`

### 3. Sample Lead Query

```sql
SELECT 
    first_name || ' ' || last_name as full_name,
    email,
    company_name,
    title
FROM public.leads 
WHERE first_name IS NOT NULL 
LIMIT 5;
```

## Troubleshooting

### Can't Connect to Database?
```bash
# Check if database is running
docker compose -f /var/www/selfhost/docker-compose.https.yml ps supabase-db

# Test connection from host
docker exec -e PGPASSWORD=supabase_secure_db_2024 supabase-db psql -U postgres -d postgres -c "SELECT COUNT(*) FROM public.leads;"
```

### N8N Can't See the Data?
1. Make sure you're using the PostgreSQL node, not HTTP
2. Use internal Docker network names (`supabase-db`, not IP addresses)
3. Check that N8N container is on the same Docker network

### Need to Update Data?
```sql
-- Add new lead
INSERT INTO public.leads (first_name, last_name, email, company_name) 
VALUES ('John', 'Doe', 'john@example.com', 'Example Corp');

-- Update existing lead
UPDATE public.leads 
SET is_email_verified = true 
WHERE email = 'ulf.krynojewski@publitec.tv';
```

## Benefits of Local Setup

✅ **No external API rate limits**  
✅ **Faster queries (no network latency)**  
✅ **Full SQL power (joins, aggregations, etc.)**  
✅ **Complete data control**  
✅ **Works offline**  
✅ **No external service dependencies**  

---

**Your 546 leads are now fully local and ready for N8N automation! 🎉**

Next: Update your existing N8N workflows to use the PostgreSQL node with the connection details above.