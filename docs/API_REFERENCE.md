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

### Qdrant Vector Database
**Base URL**: `http://217.154.225.184:6333`

```bash
# Health check
curl http://217.154.225.184:6333/health

# List collections
curl http://217.154.225.184:6333/collections

# Create collection
curl -X PUT http://217.154.225.184:6333/collections/test \
  -H "Content-Type: application/json" \
  -d '{"vectors": {"size": 384, "distance": "Cosine"}}'
```

### N8N Webhook API
**Base URL**: `http://217.154.225.184:5678`

Webhooks available after creating workflows in N8N interface.

### Dashboard API
**Base URL**: `http://217.154.225.184:3000`

Static dashboard serving system information.

## Authentication

- **Ollama**: No authentication required (internal network)
- **Qdrant**: No authentication (configure if needed)
- **N8N**: Web interface authentication
- **Open WebUI**: No authentication required (direct access)