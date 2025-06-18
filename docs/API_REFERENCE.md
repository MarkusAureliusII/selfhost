# API Reference

## Service Endpoints

### Ollama API
**Base URL**: `http://217.154.225.184:11434`

```bash
# List models
curl http://217.154.225.184:11434/api/tags

# Generate text
curl -X POST http://217.154.225.184:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "llama3.2:3b", "prompt": "Hello, how are you?"}'

# Chat completion
curl -X POST http://217.154.225.184:11434/api/chat \
  -H "Content-Type: application/json" \
  -d '{"model": "llama3.2:3b", "messages": [{"role": "user", "content": "Hello!"}]}'
```

### Supabase Backend Platform
**Base URL**: `http://217.154.225.184:6333`
**Studio UI**: `http://217.154.225.184:6333`
**REST API**: `http://217.154.225.184:6333/rest/v1/`
**Real-time**: `ws://217.154.225.184:6333/realtime/v1/websocket`

```bash
# Health check
curl http://217.154.225.184:6333/health

# List tables (REST API)
curl -H "apikey: YOUR_API_KEY" http://217.154.225.184:6333/rest/v1/

# Create table via REST API
curl -X POST http://217.154.225.184:6333/rest/v1/your_table \
  -H "Content-Type: application/json" \
  -H "apikey: YOUR_API_KEY" \
  -d '{"name": "example", "data": "value"}'

# Vector similarity search (using pgvector extension)
curl -X POST http://217.154.225.184:6333/rest/v1/rpc/match_documents \
  -H "Content-Type: application/json" \
  -H "apikey: YOUR_API_KEY" \
  -d '{"query_embedding": [0.1, 0.2, 0.3], "match_threshold": 0.8}'
```

### N8N Webhook API
**Base URL**: `http://217.154.225.184:5678`

Webhooks available after creating workflows in N8N interface.

### Dashboard API
**Base URL**: `http://217.154.225.184:3000`

Static dashboard serving system information.

## Authentication

- **Ollama**: No authentication required (internal network)
- **Supabase**: API key authentication, JWT tokens for user auth
- **N8N**: Web interface authentication
- **Open WebUI**: No authentication required (direct access)