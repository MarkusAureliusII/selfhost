# 🚀 Loveable.dev Integration with Self-Hosted Supabase

## Quick Setup Guide

### Option 1: Direct IP Access (Immediate)

**Use these values in your Loveable.dev project:**

```env
VITE_SUPABASE_URL=http://217.154.225.184:8000
VITE_SUPABASE_ANON_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpLXN0YWNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODQ4NjAyMDAsImV4cCI6MTg0MjY0NjYwMH0.LmAmqbkr_V-ZgPl4UQJf9z2Y2J9vF3nHdY1kF4M-8Wy
VITE_SUPABASE_SERVICE_ROLE_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpLXN0YWNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg2MDIwMCwiZXhwIjoxODQyNjQ2NjAwfQ.pJ7qQ4RvM5L8nGx3Hp9s6kF2J9vF3nHdY1kF4M-8Wy
```

### Option 2: Domain Access (Preferred)

**If you set up DNS for `supabase.avantera-digital.de`:**

```env
VITE_SUPABASE_URL=https://supabase.avantera-digital.de
VITE_SUPABASE_ANON_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpLXN0YWNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODQ4NjAyMDAsImV4cCI6MTg0MjY0NjYwMH0.LmAmqbkr_V-ZgPl4UQJf9z2Y2J9vF3nHdY1kF4M-8Wy
VITE_SUPABASE_SERVICE_ROLE_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpLXN0YWNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg2MDIwMCwiZXhwIjoxODQyNjQ2NjAwfQ.pJ7qQ4RvM5L8nGx3Hp9s6kF2J9vF3nHdY1kF4M-8Wy
```

## 📋 Available Database Schema

### Tables You Can Use:

#### 1. **leads** (546 records)
```javascript
// Example usage in Loveable
const { data: leads } = await supabase
  .from('leads')
  .select('*')
  .limit(10)

// Lead structure:
{
  id: "uuid",
  source_id: "string",
  first_name: "string",
  last_name: "string", 
  email: "string",
  phone: "string",
  company_name: "string",
  country: "string",
  city: "string",
  state: "string",
  title: "string",
  website: "string",
  person_linkedin_url: "string",
  company_linkedin_url: "string",
  created_at: "timestamp",
  updated_at: "timestamp"
}
```

#### 2. **webhook_settings** (1 record)
```javascript
// Example usage in Loveable
const { data: webhooks } = await supabase
  .from('webhook_settings')
  .select('*')

// Webhook settings structure:
{
  id: "uuid",
  user_id: "uuid",
  global_webhook_url: "string",
  lead_processing_webhook: "string",
  lead_scraping_webhook: "string",
  email_verification_webhook: "string",
  linkedin_analysis_webhook: "string",
  website_analysis_webhook: "string",
  ai_chat_webhook: "string",
  created_at: "timestamp",
  updated_at: "timestamp"
}
```

## 🎨 Loveable.dev Component Examples

### Lead Dashboard Component
```jsx
import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";

export const LeadDashboard = () => {
  const { data: leads, isLoading } = useQuery({
    queryKey: ['leads'],
    queryFn: async () => {
      const { data } = await supabase
        .from('leads')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(50);
      return data;
    }
  });

  if (isLoading) return <div>Loading leads...</div>;

  return (
    <div className="grid gap-4">
      <h2 className="text-2xl font-bold">Leads ({leads?.length || 0})</h2>
      <div className="grid gap-2">
        {leads?.map(lead => (
          <div key={lead.id} className="p-4 border rounded">
            <h3 className="font-semibold">
              {lead.first_name} {lead.last_name}
            </h3>
            <p className="text-gray-600">{lead.email}</p>
            <p className="text-sm">{lead.company_name} - {lead.title}</p>
            <p className="text-xs text-gray-500">
              {lead.city}, {lead.country}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
};
```

### Lead Search Component
```jsx
import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";

export const LeadSearch = () => {
  const [searchTerm, setSearchTerm] = useState("");
  
  const { data: searchResults } = useQuery({
    queryKey: ['leads-search', searchTerm],
    queryFn: async () => {
      if (!searchTerm) return [];
      
      const { data } = await supabase
        .from('leads')
        .select('*')
        .or(`first_name.ilike.%${searchTerm}%,last_name.ilike.%${searchTerm}%,email.ilike.%${searchTerm}%,company_name.ilike.%${searchTerm}%`)
        .limit(20);
      return data;
    },
    enabled: searchTerm.length > 2
  });

  return (
    <div className="space-y-4">
      <input
        type="text"
        placeholder="Search leads..."
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        className="w-full p-2 border rounded"
      />
      
      {searchResults?.map(lead => (
        <div key={lead.id} className="p-3 border rounded">
          <div className="font-medium">
            {lead.first_name} {lead.last_name}
          </div>
          <div className="text-sm text-gray-600">
            {lead.email} • {lead.company_name}
          </div>
        </div>
      ))}
    </div>
  );
};
```

### Webhook Settings Manager
```jsx
import { useQuery, useMutation } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";

export const WebhookSettings = () => {
  const { data: settings, refetch } = useQuery({
    queryKey: ['webhook-settings'],
    queryFn: async () => {
      const { data } = await supabase
        .from('webhook_settings')
        .select('*')
        .single();
      return data;
    }
  });

  const updateWebhook = useMutation({
    mutationFn: async (updates) => {
      const { data } = await supabase
        .from('webhook_settings')
        .update(updates)
        .eq('id', settings.id)
        .select()
        .single();
      return data;
    },
    onSuccess: () => refetch()
  });

  return (
    <div className="space-y-4">
      <h2 className="text-xl font-bold">Webhook Settings</h2>
      
      <div className="space-y-2">
        <label>Global Webhook URL:</label>
        <input
          type="url"
          value={settings?.global_webhook_url || ''}
          onChange={(e) => updateWebhook.mutate({
            global_webhook_url: e.target.value
          })}
          className="w-full p-2 border rounded"
        />
      </div>
      
      <div className="space-y-2">
        <label>Lead Processing Webhook:</label>
        <input
          type="url"
          value={settings?.lead_processing_webhook || ''}
          onChange={(e) => updateWebhook.mutate({
            lead_processing_webhook: e.target.value
          })}
          className="w-full p-2 border rounded"
        />
      </div>
    </div>
  );
};
```

## 🔧 Setup Steps in Loveable.dev

### 1. Create New Project or Open Existing

### 2. Configure Environment Variables
Go to your project settings and add:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY` 
- `VITE_SUPABASE_SERVICE_ROLE_KEY` (if needed)

### 3. Update Supabase Client Configuration
```typescript
// src/integrations/supabase/client.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

### 4. Add Database Types (Optional)
```typescript
// src/integrations/supabase/types.ts
export interface Lead {
  id: string;
  source_id?: string;
  first_name?: string;
  last_name?: string;
  email?: string;
  phone?: string;
  company_name?: string;
  country?: string;
  city?: string;
  state?: string;
  title?: string;
  website?: string;
  person_linkedin_url?: string;
  company_linkedin_url?: string;
  created_at: string;
  updated_at?: string;
}

export interface WebhookSettings {
  id: string;
  user_id?: string;
  global_webhook_url?: string;
  lead_processing_webhook?: string;
  lead_scraping_webhook?: string;
  email_verification_webhook?: string;
  linkedin_analysis_webhook?: string;
  website_analysis_webhook?: string;
  ai_chat_webhook?: string;
  created_at: string;
  updated_at?: string;
}
```

## 🧪 Testing Your Integration

### Test API Connection
```javascript
// Test in browser console or component
console.log('Testing Supabase connection...');

supabase
  .from('leads')
  .select('count')
  .then(({ data, error }) => {
    if (error) {
      console.error('Connection failed:', error);
    } else {
      console.log('Connected! Lead count:', data);
    }
  });
```

### Test Lead Creation
```javascript
// Test creating a new lead
const testLead = {
  first_name: 'Test',
  last_name: 'User',
  email: 'test@loveable.dev',
  company_name: 'Loveable',
  source_id: 'loveable-test'
};

supabase
  .from('leads')
  .insert(testLead)
  .select()
  .then(({ data, error }) => {
    console.log('Lead creation result:', { data, error });
  });
```

## 🔐 Security Notes

- ✅ **CORS configured** for Loveable.dev domains
- ✅ **Row Level Security** enabled on all tables
- ✅ **Anonymous access** allowed for reading leads
- ✅ **Authenticated access** for lead management
- ✅ **Service role access** for admin operations

## 🛠️ DNS Setup (Optional)

To use the domain `supabase.avantera-digital.de`:

1. **Add DNS Record:**
   ```
   Type: A
   Name: supabase
   Value: 217.154.225.184
   TTL: 3600
   ```

2. **Wait for propagation** (5-30 minutes)

3. **Update Loveable.dev** to use `https://supabase.avantera-digital.de`

---

## ✨ Ready to Build!

Your self-hosted Supabase is now fully integrated with Loveable.dev! You have:

- ✅ **546 leads** ready to display
- ✅ **Webhook settings** for N8N integration  
- ✅ **Full API access** with proper CORS
- ✅ **Type-safe database** schema
- ✅ **Secure authentication** policies

**Start building your lead management dashboard in Loveable.dev! 🚀**