# Supabase Migration Guide

## Quick Migration Steps

### 1. Migrate Your Leads Data

Run this command with your external Supabase details:

```bash
./scripts/import-leads.sh 'https://your-project.supabase.co' 'your_service_role_key'
```

**Replace with your actual values:**
- `https://your-project.supabase.co` - Your external Supabase project URL
- `your_service_role_key` - Your external Supabase service role key

### 2. Update N8N Workflows

In your N8N workflows, use these connection details:

**HTTP Request Node Configuration:**
- **URL**: `http://217.154.225.184:8000/rest/v1/leads`
- **Method**: `GET` (or `POST`, `PUT`, `DELETE` as needed)
- **Headers**:
  ```
  apikey: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpLXN0YWNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg2MDIwMCwiZXhwIjoxODQyNjQ2NjAwfQ.pJ7qQ4RvM5L8nGx3Hp9s6kF2J9vF3nHdY1kF4M-8Wy
  Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpLXN0YWNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg2MDIwMCwiZXhwIjoxODQyNjQ2NjAwfQ.pJ7qQ4RvM5L8nGx3Hp9s6kF2J9vF3nHdY1kF4M-8Wy
  Content-Type: application/json
  ```

### 3. Local Supabase Endpoints

**Your self-hosted Supabase is available at:**
- **API Base URL**: `http://217.154.225.184:8000`
- **Studio (Admin Interface)**: `http://217.154.225.184:6333`
- **Database Direct**: `http://217.154.225.184:5432`

### 4. Common API Operations

#### Get All Leads
```bash
curl -H "apikey: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpLXN0YWNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg2MDIwMCwiZXhwIjoxODQyNjQ2NjAwfQ.pJ7qQ4RvM5L8nGx3Hp9s6kF2J9vF3nHdY1kF4M-8Wy" \
     -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpLXN0YWNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg2MDIwMCwiZXhwIjoxODQyNjQ2NjAwfQ.pJ7qQ4RvM5L8nGx3Hp9s6kF2J9vF3nHdY1kF4M-8Wy" \
     http://217.154.225.184:8000/rest/v1/leads
```

#### Filter Leads by Status
```bash
curl -H "apikey: ..." \
     -H "Authorization: Bearer ..." \
     "http://217.154.225.184:8000/rest/v1/leads?status=eq.new"
```

#### Create New Lead
```bash
curl -X POST \
     -H "apikey: ..." \
     -H "Authorization: Bearer ..." \
     -H "Content-Type: application/json" \
     -d '{"name":"John Doe","email":"john@example.com","source":"website"}' \
     http://217.154.225.184:8000/rest/v1/leads
```

## Leads Table Structure

```sql
CREATE TABLE public.leads (
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
    metadata JSONB,
    tags TEXT[],
    score INTEGER DEFAULT 0,
    assigned_to TEXT,
    last_contact TIMESTAMP WITH TIME ZONE
);
```

## N8N Supabase Node Configuration

If using the dedicated Supabase node in N8N:

1. **Go to Credentials** in N8N
2. **Create New Credential** → **Supabase API**
3. **Enter Details**:
   - **Supabase URL**: `http://217.154.225.184:8000`
   - **API Key**: `eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpLXN0YWNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg2MDIwMCwiZXhwIjoxODQyNjQ2NjAwfQ.pJ7qQ4RvM5L8nGx3Hp9s6kF2J9vF3nHdY1kF4M-8Wy`

## Troubleshooting

### Connection Issues
```bash
# Test local Supabase
curl http://217.154.225.184:8000/rest/v1/ \
     -H "apikey: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpLXN0YWNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg2MDIwMCwiZXhwIjoxODQyNjQ2NjAwfQ.pJ7qQ4RvM5L8nGx3Hp9s6kF2J9vF3nHdY1kF4M-8Wy"

# Check services
docker compose -f /var/www/selfhost/docker-compose.https.yml ps | grep supabase

# Restart if needed
docker compose -f /var/www/selfhost/docker-compose.https.yml restart supabase-kong supabase-rest
```

### Database Access
```bash
# Direct database access
docker exec -e PGPASSWORD=supabase_secure_db_2024 supabase-db psql -U postgres -d postgres

# Check table
\dt public.leads
SELECT COUNT(*) FROM public.leads;
```

## Migration Verification

After migration, verify everything works:

1. **Check data**: Visit `http://217.154.225.184:6333` (Supabase Studio)
2. **Test API**: Use the curl commands above
3. **Update N8N**: Change your workflow connections to local endpoints
4. **Test workflows**: Run your N8N workflows to ensure they work with local data

---

**Next Steps:**
1. Run the migration script with your external Supabase details
2. Update your N8N workflows to use the local endpoints
3. Test everything works as expected

Your leads data will now be completely local and under your control! 🎉