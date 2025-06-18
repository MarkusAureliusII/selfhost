# CLAUDE.md - Self-Hosted AI Stack Context

## Project Overview
Professional self-hosted AI infrastructure running on a high-performance VPS (Debian 12, 6 CPU cores, 24GB RAM, 360GB SSD) with enterprise-grade reliability and security. Domain: `avantera-digital.de`, IP: `217.154.225.184`.

## Architecture
- **Traefik**: Reverse proxy with automatic HTTPS (Let's Encrypt)
- **N8N**: Workflow automation platform with PostgreSQL backend
- **Ollama**: Local LLM server with 12+ models (llama3.1:70b, codellama:34b, mixtral:8x7b, etc.)
- **Open WebUI**: German ChatGPT-like interface for Ollama models
- **Supabase**: Complete backend platform with PostgreSQL, real-time APIs, authentication, and vector capabilities
- **PostgreSQL**: Primary database for N8N
- **Dashboard**: Custom VPS overview with API keys section

## Service Endpoints
- VPS Dashboard: http://217.154.225.184:3000 (main overview)
- Open WebUI: http://217.154.225.184:3001 (ChatGPT interface - instant access)
- N8N: http://217.154.225.184:5678 (workflow automation)
- Supabase Studio: http://217.154.225.184:6333 (backend platform with database UI)
- Traefik Dashboard: http://217.154.225.184:8080 (load balancer)
- Ollama API: http://217.154.225.184:11434 (LLM server)

## Documentation and Dependencies

### Project Documentation
- Always keep README updated with:
  - Current information
  - Terminal commands
  - Service configurations
  - Endpoint details
  - Dependency requirements

### System Dependencies
- Docker
- Docker Compose
- Debian 12
- Let's Encrypt CLI
- htop (system monitoring)
- curl (API testing)

### Setup Steps
1. Install Debian 12
2. Install Docker and Docker Compose
3. Clone project repository
4. Configure `.env` file with credentials
5. Set up SSL certificates
6. Run `docker-compose -f docker-compose.https.yml up -d`

### Environment Requirements
- Minimum 24GB RAM
- 6+ CPU cores
- 360GB+ SSD storage
- Stable internet connection
- Domain with SSL support

## Common Commands

### Service Management
```bash
# Start main stack
docker-compose -f docker-compose.https.yml up -d

# Start Traefik proxy
docker-compose -f traefik.yml up -d

# Check service status
docker-compose -f docker-compose.https.yml ps
./check-services.sh

# View logs
docker-compose -f docker-compose.https.yml logs [service_name]
```

### Monitoring
```bash
# Resource usage
docker stats --no-stream
./monitoring-commands.sh

# System resources
htop
df -h
free -h
```

### Ollama Model Management
```bash
# List installed models (12+ available)
docker exec ollama ollama list

# Premium models (70B parameters):
# - llama3.1:70b (best text quality)
# - mixtral:8x7b (mixture of experts)

# Code-specialized models:
# - codellama:34b / codellama:13b
# - deepseek-coder:6.7b

# Multimodal models:
# - llama3.2-vision:11b (text + images)

# Fast, compact models:
# - llama3.2:3b, mistral:7b, neural-chat:7b
# - phi3:14b, gemma2:9b, qwen2.5:14b

# Test API directly
curl http://217.154.225.184:11434/api/tags
```

## Professional File Structure
- `config/`: Configuration files and settings
- `data/`: Application data and shared storage
- `scripts/`: Utility scripts for management
- `ssl/`: SSL certificates and security configuration
- `dashboard/`: Custom VPS monitoring dashboard
- `docs/`: Project documentation
- `logs/`: Application logs
- `docker-compose.https.yml`: Main services configuration
- `traefik.yml`: Reverse proxy configuration
- `.env`: Environment variables (secure, not in git)
- `README.md`: Comprehensive documentation

## Resource Configuration
High-performance setup with flexible memory allocation:
- **Ollama**: 6GB reserved, can use up to 20GB for large models
- **N8N**: 1GB reserved, can expand for complex workflows
- **PostgreSQL**: 2GB reserved, 8GB limit with performance tuning
- **Supabase**: 1GB reserved, can expand for complex backend operations including vector storage and real-time features

## Development Notes
- Uses flexible memory reservations instead of hard limits
- CPU cores shared dynamically between services
- Optimized for AI/ML workloads with large models
- All services accessible via both domain and direct IP:port

## Environment Variables
Stored in `.env` file (not in repo):
- Database credentials
- N8N encryption keys
- SSL/TLS configuration

## Security
- Automatic HTTPS with Let's Encrypt
- Security headers via Traefik middleware
- Internal Docker networks for service communication
- PostgreSQL and other databases not exposed externally

## Maintenance Reminder
- Immer das readme mit aktuellen Informationen, Befehlen, und domains updaten

## Memory Notes
- From now on each run fill out and ChangeLog file ChangeLogsCAUDE.md
- When creating new files (Ordnerstruktur de) always keep good file structure from a technical, functional and privacy level then decide where to put the new file