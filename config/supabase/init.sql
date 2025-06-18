-- Supabase Self-Hosted Initial Setup with pgvector for AI Embeddings
-- This script sets up all necessary users, extensions, and schemas for Supabase

-- Create extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create pgvector extension for AI embeddings
CREATE EXTENSION IF NOT EXISTS vector;

-- Create additional useful extensions
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Create Supabase service users
CREATE ROLE anon nologin noinherit;
CREATE ROLE authenticated nologin noinherit;
CREATE ROLE service_role nologin noinherit bypassrls;

-- Create admin users for Supabase services
CREATE ROLE supabase_admin WITH LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION PASSWORD 'supabase_secure_db_2024';
CREATE ROLE supabase_auth_admin WITH LOGIN NOSUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION PASSWORD 'supabase_secure_db_2024';
CREATE ROLE supabase_storage_admin WITH LOGIN NOSUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION PASSWORD 'supabase_secure_db_2024';
CREATE ROLE supabase_realtime_admin WITH LOGIN NOSUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION PASSWORD 'supabase_secure_db_2024';

-- Create authenticator role (used by PostgREST)
CREATE ROLE authenticator WITH LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER PASSWORD 'supabase_secure_db_2024';

-- Grant privileges
GRANT anon, authenticated, service_role TO authenticator;
GRANT ALL ON DATABASE postgres TO supabase_admin;
GRANT ALL ON DATABASE postgres TO supabase_auth_admin;
GRANT ALL ON DATABASE postgres TO supabase_storage_admin;
GRANT ALL ON DATABASE postgres TO supabase_realtime_admin;

-- Create auth schema for GoTrue
CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION supabase_auth_admin;

-- Create storage schema for Supabase Storage
CREATE SCHEMA IF NOT EXISTS storage AUTHORIZATION supabase_storage_admin;

-- Create realtime schema for Supabase Realtime
CREATE SCHEMA IF NOT EXISTS _realtime AUTHORIZATION supabase_realtime_admin;

-- Create extensions schema
CREATE SCHEMA IF NOT EXISTS extensions AUTHORIZATION postgres;

-- Grant usage on schemas
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA auth TO postgres, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA storage TO postgres, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA extensions TO postgres, anon, authenticated, service_role;

-- Grant all on public schema tables
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, anon, authenticated, service_role;

-- Grant all on storage schema tables
GRANT ALL ON ALL TABLES IN SCHEMA storage TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA storage TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA storage TO postgres, anon, authenticated, service_role;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres, anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT ALL ON TABLES TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres, anon, authenticated, service_role;

-- Create AI/ML tables for embeddings
CREATE TABLE IF NOT EXISTS public.ai_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content TEXT NOT NULL,
    embedding vector(1536), -- OpenAI ada-002 dimensionality
    metadata JSONB DEFAULT '{}',
    source VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for vector similarity search
CREATE INDEX IF NOT EXISTS ai_embeddings_embedding_idx ON public.ai_embeddings 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Create index for metadata queries
CREATE INDEX IF NOT EXISTS ai_embeddings_metadata_idx ON public.ai_embeddings USING GIN (metadata);

-- Create index for source queries
CREATE INDEX IF NOT EXISTS ai_embeddings_source_idx ON public.ai_embeddings (source);

-- Create table for AI models metadata
CREATE TABLE IF NOT EXISTS public.ai_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    parameters BIGINT,
    size_gb DECIMAL(10,2),
    type VARCHAR(100) NOT NULL, -- 'llm', 'embedding', 'vision', etc.
    provider VARCHAR(100), -- 'ollama', 'openai', 'huggingface', etc.
    status VARCHAR(50) DEFAULT 'available', -- 'available', 'loading', 'error'
    config JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create table for chat conversations
CREATE TABLE IF NOT EXISTS public.chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255),
    user_id UUID, -- Will be linked to auth.users later
    model_name VARCHAR(255) REFERENCES ai_models(name),
    system_prompt TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create table for chat messages
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES chat_conversations(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create table for N8N workflow data
CREATE TABLE IF NOT EXISTS public.n8n_workflow_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id VARCHAR(255) NOT NULL,
    execution_id VARCHAR(255),
    data JSONB NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create table for webhook logs
CREATE TABLE IF NOT EXISTS public.webhook_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source VARCHAR(255) NOT NULL,
    method VARCHAR(10) NOT NULL,
    url TEXT NOT NULL,
    headers JSONB DEFAULT '{}',
    body JSONB DEFAULT '{}',
    response_status INTEGER,
    response_body TEXT,
    processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create RLS (Row Level Security) policies
ALTER TABLE public.ai_embeddings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_models ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.n8n_workflow_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.webhook_logs ENABLE ROW LEVEL SECURITY;

-- Create policies for anon access (read-only for public data)
CREATE POLICY "Allow anon read access to ai_models" ON public.ai_models FOR SELECT USING (true);
CREATE POLICY "Allow anon read access to ai_embeddings" ON public.ai_embeddings FOR SELECT USING (true);

-- Create policies for authenticated users (simplified for now, will be enhanced when GoTrue is running)
CREATE POLICY "Allow authenticated users read conversations" ON public.chat_conversations FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users insert conversations" ON public.chat_conversations FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow authenticated users update conversations" ON public.chat_conversations FOR UPDATE USING (true);

CREATE POLICY "Allow authenticated users read messages" ON public.chat_messages FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users insert messages" ON public.chat_messages FOR INSERT WITH CHECK (true);

-- Create policies for service_role (full access)
CREATE POLICY "Allow service_role full access to all embeddings" ON public.ai_embeddings FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');
CREATE POLICY "Allow service_role full access to ai_models" ON public.ai_models FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');
CREATE POLICY "Allow service_role full access to n8n_workflow_data" ON public.n8n_workflow_data FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');
CREATE POLICY "Allow service_role full access to webhook_logs" ON public.webhook_logs FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

-- Insert default AI models
INSERT INTO public.ai_models (name, description, parameters, size_gb, type, provider, config) VALUES
('llama3.1:8b', '🚀 Premium LLM - Sehr gute Balance aus Leistung und Effizienz', 8000000000, 4.9, 'llm', 'ollama', '{"context_length": 128000}'),
('codellama:13b', '💻 Code-Spezialist - Programmierung, Debugging, Code-Reviews', 13000000000, 7.4, 'llm', 'ollama', '{"context_length": 16384, "specialty": "code"}'),
('mixtral:8x7b', '🧠 Mixture of Experts - Vielseitig, mehrsprachig, effizient', 46700000000, 26.4, 'llm', 'ollama', '{"context_length": 32768, "experts": 8}'),
('llama3.2-vision:11b', '👁️ Multimodal - Text + Bilder verstehen und analysieren', 11000000000, 7.8, 'vision', 'ollama', '{"context_length": 128000, "supports_images": true}'),
('deepseek-coder:6.7b', '🔧 DeepSeek Coder - Spezialisiert auf Code-Generierung', 6700000000, 3.8, 'llm', 'ollama', '{"context_length": 16384, "specialty": "code"}'),
('qwen2.5:14b', '🌟 Qwen2.5 - Ausgewogenes Allround-Modell, mehrsprachig', 14800000000, 9.0, 'llm', 'ollama', '{"context_length": 32768}'),
('qwen2.5:3b', '🏎️ Qwen2.5 Compact - Sehr schnell mit guter Qualität', 3000000000, 1.9, 'llm', 'ollama', '{"context_length": 32768}'),
('gemma2:9b', '📚 Google Gemma2 - Factual, präzise Antworten', 9200000000, 5.4, 'llm', 'ollama', '{"context_length": 8192}'),
('gemma2:2b', '⚡ Google Gemma2 Mini - Ultra-effizient, nur 2.5GB RAM', 2000000000, 1.6, 'llm', 'ollama', '{"context_length": 8192}'),
('phi3:14b', '🎯 Microsoft Phi3 - Kompakt aber leistungsstark', 14000000000, 7.9, 'llm', 'ollama', '{"context_length": 128000}'),
('neural-chat:7b', '💬 Neural Chat - Optimiert für Unterhaltungen', 7000000000, 4.1, 'llm', 'ollama', '{"context_length": 8192, "specialty": "chat"}'),
('mistral:7b', '⚡ Mistral - Schnell und effizient für alltägliche Aufgaben', 7200000000, 4.1, 'llm', 'ollama', '{"context_length": 32768}'),
('llama3.2:3b', '🏃 Ultra-schnell - Minimale Latenz für einfache Fragen', 3200000000, 2.0, 'llm', 'ollama', '{"context_length": 128000}'),
('nomic-embed-text:latest', '🔍 Embedding-Modell - Für Textsuche und Ähnlichkeitsvergleiche', 137000000, 0.3, 'embedding', 'ollama', '{"dimensions": 768})
ON CONFLICT (name) DO NOTHING;

-- Create functions for vector similarity search
CREATE OR REPLACE FUNCTION public.match_embeddings(
    query_embedding vector(1536),
    match_threshold float DEFAULT 0.8,
    match_count int DEFAULT 10
)
RETURNS TABLE (
    id uuid,
    content text,
    metadata jsonb,
    source varchar(255),
    similarity float
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        ai_embeddings.id,
        ai_embeddings.content,
        ai_embeddings.metadata,
        ai_embeddings.source,
        1 - (ai_embeddings.embedding <=> query_embedding) AS similarity
    FROM public.ai_embeddings
    WHERE 1 - (ai_embeddings.embedding <=> query_embedding) > match_threshold
    ORDER BY similarity DESC
    LIMIT match_count;
$$;

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_ai_embeddings_updated_at 
    BEFORE UPDATE ON public.ai_embeddings 
    FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE TRIGGER update_ai_models_updated_at 
    BEFORE UPDATE ON public.ai_models 
    FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE TRIGGER update_chat_conversations_updated_at 
    BEFORE UPDATE ON public.chat_conversations 
    FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE TRIGGER update_n8n_workflow_data_updated_at 
    BEFORE UPDATE ON public.n8n_workflow_data 
    FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION public.match_embeddings TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.update_updated_at_column TO anon, authenticated, service_role;

-- Create a view for public model information
CREATE OR REPLACE VIEW public.available_models AS
SELECT 
    name,
    description,
    parameters,
    size_gb,
    type,
    provider,
    status,
    config->'context_length' as context_length,
    config->'specialty' as specialty,
    created_at
FROM public.ai_models
WHERE status = 'available';

-- Grant access to the view
GRANT SELECT ON public.available_models TO anon, authenticated, service_role;

-- Final message
SELECT 'Supabase initialization completed successfully with pgvector support!' as status;