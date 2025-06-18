# 🚀 Self-Hosted AI Stack - Professional Setup

## 📋 Project Overview

A comprehensive self-hosted AI infrastructure running on a high-performance VPS, featuring workflow automation, large language models, vector databases, and modern DevOps practices. This setup provides a complete AI development and production environment with enterprise-grade reliability.

## 🏗️ Project Structure

```
/var/www/selfhost/
├── 📁 config/                    # Configuration files
│   └── traefik-config/          # Traefik dynamic configuration
├── 📁 data/                     # Application data
│   └── shared/                  # Shared data between services
│       └── files/               # N8N file storage
├── 📁 dashboard/                # VPS monitoring dashboard
├── 📁 docs/                     # Project documentation
├── 📁 logs/                     # Application logs
├── 📁 scripts/                  # Utility scripts
│   ├── check-services.sh        # Service health checker
│   ├── get-docker.sh           # Docker installation script
│   ├── monitoring-commands.sh   # System monitoring utilities
│   ├── setup-swap.sh           # Swap configuration script
│   └── start-services.sh       # Service startup script
├── 📁 ssl/                      # SSL certificates and configuration
│   └── letsencrypt/            # Let's Encrypt certificates
├── 📁 self-hosted-ai-starter-kit/ # Original starter kit files
├── docker-compose.https.yml      # Main services configuration
├── traefik.yml                  # Reverse proxy configuration
├── .env                         # Environment variables (secure)
├── CLAUDE.md                    # AI assistant context file
└── README.md                    # This documentation
```

## 🛠️ Technology Stack

### Core Infrastructure
- **Docker & Docker Compose**: Container orchestration and service management
- **Traefik v3.0**: Reverse proxy, load balancer, automatic SSL/TLS
- **PostgreSQL 16**: Primary database for application data
- **Debian 12**: Stable Linux foundation with security updates

### AI & Machine Learning Services

#### **Ollama** - Local LLM Server
- **Image**: `ollama/ollama:latest`
- **Purpose**: Host and serve large language models locally
- **API Endpoint**: http://217.154.225.184:11434
- **Models Installed (12+)**:
  - `llama3.1:70b` - Premium 70B parameter model (best quality)
  - `codellama:34b` / `codellama:13b` - Code generation specialists  
  - `llama3.2-vision:11b` - Multimodal (text + images)
  - `mixtral:8x7b` - Mixture of Experts architecture
  - `mistral:7b` - Efficient general-purpose model
  - `phi3:14b` - Microsoft's optimized model
  - `neural-chat:7b` - Conversation optimized
  - `gemma2:9b` - Google's Gemma 2
  - `qwen2.5:14b` - Alibaba's Qwen model
  - `deepseek-coder:6.7b` - Code specialist
  - `nomic-embed-text` - Text embeddings

#### **Open WebUI** - ChatGPT-like Interface
- **Image**: `ghcr.io/open-webui/open-webui:main`
- **Purpose**: User-friendly web interface for Ollama models
- **Access**: http://217.154.225.184:3001 (Direct access, no registration)
- **Features**: Clean ChatGPT-like UI, model switching, conversation history, instant access

#### **N8N** - Workflow Automation Platform
- **Image**: `n8nio/n8n:latest`
- **Purpose**: AI workflow automation and API integration
- **Access**: http://217.154.225.184:5678
- **Features**: 
  - PostgreSQL backend for persistence
  - Ollama integration for AI workflows
  - High-performance configuration (200 concurrent workflows)
  - Enhanced payload limits (128MB)

#### **Qdrant** - Vector Database
- **Image**: `qdrant/qdrant:latest`
- **Purpose**: Store and search vector embeddings for RAG applications
- **Access**: http://217.154.225.184:6333
- **Features**: CORS enabled, optimized for AI/ML workloads

### Supporting Services

#### **Traefik** - Reverse Proxy & Load Balancer
- **Image**: `traefik:v3.0`
- **Purpose**: Route traffic, SSL termination, service discovery
- **Dashboard**: http://217.154.225.184:8080
- **Features**: Automatic HTTPS with Let's Encrypt, security headers

#### **VPS Dashboard**
- **Image**: `nginx:alpine`
- **Purpose**: System overview and service monitoring
- **Access**: http://217.154.225.184:3000

## 🌐 Service Endpoints

| Service | URL | Purpose |
|---------|-----|---------|
| **VPS Dashboard** | http://217.154.225.184:3000 | System overview and monitoring |
| **Open WebUI** | http://217.154.225.184:3001 | ChatGPT-like interface (instant access) |
| **N8N Workflows** | http://217.154.225.184:5678 | Workflow automation platform |
| **Qdrant Vector DB** | http://217.154.225.184:6333 | Vector database API |
| **Traefik Dashboard** | http://217.154.225.184:8080 | Load balancer management |
| **Ollama API** | http://217.154.225.184:11434 | LLM server API |

## 📊 System Specifications

### VPS Configuration
- **OS**: Debian 12 (Bookworm)
- **CPU**: 6 cores
- **RAM**: 24GB
- **Storage**: 360GB SSD
- **Swap**: 4GB (configured for large AI models)
- **IPv4**: 217.154.225.184
- **IPv6**: 2a01:239:27f:d000::1

### Resource Allocation Strategy
- **Flexible Memory Management**: Services share resources dynamically
- **CPU Sharing**: No hard limits, automatic load balancing
- **Storage Optimization**: Dedicated volumes for persistent data

## 🚀 Installation & Setup

### Prerequisites
- Root access to VPS
- Internet connection for downloads
- Domain access (optional for HTTPS)

### Step 1: Initial Setup
```bash
# Clone or upload project files to /var/www/selfhost/
cd /var/www/selfhost

# Install Docker (if not already installed)
chmod +x scripts/get-docker.sh
./scripts/get-docker.sh

# Setup swap space for large AI models
chmod +x scripts/setup-swap.sh
./scripts/setup-swap.sh
```

### Step 2: Configure Environment
```bash
# Copy and customize environment variables
cp .env.example .env
nano .env

# Required variables:
# POSTGRES_DB=n8n_db
# POSTGRES_USER=n8n_user  
# POSTGRES_PASSWORD=your_secure_password
# N8N_ENCRYPTION_KEY=your_encryption_key
# N8N_USER_MANAGEMENT_JWT_SECRET=your_jwt_se
now i wnat every singly apt
# WEBUI_SECRET_KEY=your_webui_secret
```

### Step 3: Create Docker Networks
```bash
# Create required Docker networks
docker network create web
docker network create demo
```

### Step 4: Start Services
```bash
# Start Traefik reverse proxy first
docker compose -f traefik.yml up -d

# Start main AI stack
docker compose -f docker-compose.https.yml up -d

# Verify services are running
chmod +x scripts/check-services.sh
./scripts/check-services.sh
```

### Step 5: AI Model Setup
The system automatically downloads 12+ AI models on first startup. This process takes 30-60 minutes depending on internet speed.

```bash
# Check model download progress
docker logs ollama-setup -f

# List available models after download
docker exec ollama ollama list
```

## 🔧 Management Commands

### Service Management
```bash
# Start all services
docker compose -f docker-compose.https.yml up -d

# Stop all services  
docker compose -f docker-compose.https.yml down

# Restart specific service
docker compose -f docker-compose.https.yml restart [service_name]

# View service logs
docker compose -f docker-compose.https.yml logs [service_name] -f
```

### System Monitoring
```bash
# Check service health
./scripts/check-services.sh

# Monitor resource usage
docker stats --no-stream

# System monitoring
./scripts/monitoring-commands.sh

# Check disk usage
df -h
du -sh /var/lib/docker/volumes/*
```

### Ollama Model Management
```bash
# List installed models
docker exec ollama ollama list

# Download new model
docker exec ollama ollama pull model_name:tag

# Remove model
docker exec ollama ollama rm model_name:tag

# Test API directly
curl http://217.154.225.184:11434/api/tags
```

### Database Operations
```bash
# Access PostgreSQL
docker exec -it selfhost-postgres-1 psql -U n8n_user -d n8n_db

# Backup database
docker exec selfhost-postgres-1 pg_dump -U n8n_user n8n_db > backup.sql

# Restore database
docker exec -i selfhost-postgres-1 psql -U n8n_user -d n8n_db < backup.sql
```

## 🔒 Security Configuration

### Environment Variables
- All sensitive data stored in `.env` file (excluded from git)
- Database credentials, encryption keys, JWT secrets
- SSL/TLS configuration for secure communication

### Network Security
- Internal Docker networks for service communication
- Traefik security headers enabled
- PostgreSQL not exposed externally
- Automatic HTTPS with Let's Encrypt

### Firewall Recommendations
```bash
# Basic UFW configuration
ufw allow 22/tcp      # SSH
ufw allow 80/tcp      # HTTP (redirects to HTTPS)
ufw allow 443/tcp     # HTTPS
ufw allow 3000:3001/tcp  # Dashboard & WebUI
ufw allow 5678/tcp    # N8N
ufw allow 6333/tcp    # Qdrant
ufw allow 8080/tcp    # Traefik Dashboard
ufw allow 11434/tcp   # Ollama API
ufw enable
```

## 📈 Performance Optimization

### Memory Management
- **Flexible Allocation**: Services use `mem_reservation` instead of hard limits
- **Dynamic Scaling**: Ollama can use up to 20GB for large models
- **Swap Configuration**: 4GB swap for memory spikes

### CPU Optimization
- **No CPU Limits**: Services share all 6 cores dynamically
- **Parallel Processing**: Ollama configured for 6 parallel requests
- **Load Balancing**: Traefik distributes requests efficiently

### Storage Optimization
```bash
# Recommended volume allocation (360GB total):
# - Ollama models: 150GB
# - Qdrant vectors: 100GB  
# - PostgreSQL data: 50GB
# - Backups: 30GB
# - N8N workflows: 20GB
# - Monitoring: 10GB
```

## 🔄 Backup & Recovery

### Automated Backup Strategy
```bash
# Database backup
docker exec selfhost-postgres-1 pg_dump -U n8n_user n8n_db | gzip > backups/postgres_$(date +%Y%m%d_%H%M%S).sql.gz

# N8N workflows backup
docker run --rm -v selfhost_n8n_storage:/data -v $(pwd)/backups:/backup alpine tar czf /backup/n8n_$(date +%Y%m%d_%H%M%S).tar.gz /data

# Qdrant vectors backup
docker run --rm -v selfhost_qdrant_storage:/data -v $(pwd)/backups:/backup alpine tar czf /backup/qdrant_$(date +%Y%m%d_%H%M%S).tar.gz /data
```

### Recovery Procedures
```bash
# Restore database
gunzip < backup.sql.gz | docker exec -i selfhost-postgres-1 psql -U n8n_user -d n8n_db

# Restore N8N data
docker run --rm -v selfhost_n8n_storage:/data -v $(pwd)/backups:/backup alpine tar xzf /backup/n8n_backup.tar.gz -C /
```

## 🚨 Troubleshooting

### Common Issues

#### Services Not Starting
```bash
# Check Docker status
systemctl status docker

# Check container logs
docker logs [container_name] --tail 50

# Verify networks exist
docker network ls
```

#### Permission Errors
```bash
# Fix N8N shared directory permissions
chmod -R 777 /var/www/selfhost/data/shared

# Fix SSL certificate permissions  
chmod 600 /var/www/selfhost/ssl/letsencrypt/acme.json
```

#### Memory Issues
```bash
# Check system memory
free -h

# Monitor container memory usage
docker stats

# Increase swap if needed
sudo fallocate -l 8G /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

#### Network Connectivity
```bash
# Test service endpoints
curl -I http://217.154.225.184:3000
curl -I http://217.154.225.184:11434

# Check Docker networks
docker network inspect web
docker network inspect demo
```

### Log Files
```bash
# Application logs location
./logs/

# Container logs
docker logs [container_name] -f

# System logs
journalctl -u docker -f
```

## 🔄 Updates & Maintenance

### Regular Maintenance Tasks
```bash
# Update Docker images
docker compose -f docker-compose.https.yml pull
docker compose -f docker-compose.https.yml up -d

# Clean up unused resources
docker system prune -f
docker volume prune -f

# Update system packages
apt update && apt upgrade -y
```

### Adding New AI Models
```bash
# Download specific model
docker exec ollama ollama pull llama3.2:1b

# List available models online
curl https://ollama.ai/library

# Configure model in Open WebUI
# Go to http://217.154.225.184:3001 -> Settings -> Models
```

## 📚 Development Guidelines

### Adding New Services
1. Update `docker-compose.https.yml`
2. Add service configuration
3. Update this README
4. Test thoroughly before deployment

### Environment Variables
- Add new variables to `.env.example`
- Document in this README
- Never commit sensitive data to git

### Custom Configuration
- Place custom configs in `config/` directory
- Use volume mounts for persistent data
- Follow security best practices

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create feature branch
3. Update documentation
4. Test changes thoroughly
5. Submit pull request

### Code Standards
- Use meaningful commit messages
- Update README for any changes
- Follow Docker best practices
- Test on staging environment first

## 📞 Support & Documentation

### Useful Resources
- [Docker Documentation](https://docs.docker.com/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Ollama Documentation](https://ollama.ai/docs)
- [N8N Documentation](https://docs.n8n.io/)
- [Qdrant Documentation](https://qdrant.tech/documentation/)

### Getting Help
- Check logs first: `docker logs [service_name]`
- Review this documentation
- Search existing issues
- Create detailed issue reports

---

## 📝 Change Log

### v1.0.0 - Initial Release
- ✅ Complete AI stack deployment
- ✅ Professional directory structure
- ✅ Comprehensive documentation
- ✅ Security hardening
- ✅ Performance optimization
- ✅ Automated model downloads
- ✅ Health monitoring scripts

### System Information
- **Deployed**: June 17, 2025
- **VPS**: Debian 12, 6 CPU cores, 24GB RAM, 360GB SSD
- **Docker**: 28.2.2
- **Network**: IPv4: 217.154.225.184
- **Domain**: avantera-digital.de (configured for HTTPS)

---

*This setup provides enterprise-grade AI infrastructure with professional DevOps practices, security hardening, and comprehensive monitoring.*