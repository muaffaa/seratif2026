# 🐳 Seratif 2026 - Docker Containerization Guide

## 📖 Table of Contents
1. [Quick Start](#quick-start)
2. [Architecture](#architecture)
3. [File Structure](#file-structure)
4. [Development Setup](#development-setup)
5. [Production Setup](#production-setup)
6. [Commands Reference](#commands-reference)
7. [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### Prerequisites
- **Docker** 20.10+ ([Download](https://www.docker.com/products/docker-desktop))
- **Docker Compose** 3.8+ (included with Docker Desktop)
- **Linux/Mac/Windows** with 2GB+ RAM

### One-Command Setup
```bash
cd /home/muaffaa/Documents/myRepo/seratif2026

# Make setup script executable
chmod +x setup.sh

# Run automated setup
./setup.sh
```

This will automatically:
- ✅ Check Docker installation
- ✅ Configure environment variables
- ✅ Build Docker images
- ✅ Start all containers
- ✅ Initialize database
- ✅ Show access information

### Manual Setup
```bash
# 1. Setup environment
cp .env.docker .env

# 2. Build images
docker-compose build

# 3. Start services
docker-compose up -d

# 4. Wait for database (~30s)
sleep 30

# 5. Access services
echo "Frontend: http://localhost"
echo "Backend: http://localhost:8000"
echo "phpMyAdmin: http://localhost:8080"
```

---

## 🏗️ Architecture

### Service Topology
```
┌─────────────────────────────────────────────────────┐
│               External Network                       │
│  (Browser: http://localhost)                        │
└──────────────┬──────────────────────────────────────┘
               │ HTTP/HTTPS
         ┌─────▼─────────────┐
         │   Nginx Frontend  │ (Port 80)
         │  - SPA routing    │
         │  - Static caching │
         │  - API proxy      │
         └─────┬─────────────┘
               │
        ┌──────▼──────────────────┐
        │   Docker Network        │
        │   seratif_network       │
        │                         │
        │  ┌────────────────┐    │
        │  │ PHP Backend    │    │
        │  │ Apache Server  │    │
        │  │ - API endpoints│    │
        │  │ - QR generation│    │
        │  │ - PDF export   │    │
        │  └────────┬───────┘    │
        │           │            │
        │     ┌─────▼─────┐     │
        │     │  MySQL 8  │     │
        │     │  Database │     │
        │     └───────────┘     │
        │                         │
        │  ┌────────────────┐    │
        │  │  phpMyAdmin    │    │
        │  │  (optional)    │    │
        │  └────────────────┘    │
        │                         │
        └─────────────────────────┘
```

### Service Details

| Service | Image | Port | Purpose | Status |
|---------|-------|------|---------|--------|
| **frontend** | nginx:alpine | 80 | React SPA + API proxy | Health check every 30s |
| **backend** | php:8.1-apache | 8000 | PHP API server | Health check every 30s |
| **db** | mysql:8.0 | 3306 | Database server | Health check every 10s |
| **phpmyadmin** | phpmyadmin:latest | 8080 | DB management UI | Optional |

---

## 📁 File Structure

```
seratif2026/
├── 📄 docker-compose.yml           # Main orchestration (production)
├── 📄 docker-compose.dev.yml       # Development setup
├── 📄 docker-compose.prod.yml      # Production optimized
├── 📄 Dockerfile.backend           # PHP/Apache container
├── 📄 Dockerfile.frontend          # Node/Nginx container
├── 📄 nginx.conf                   # Nginx config (dev)
├── 📄 nginx.prod.conf              # Nginx config (prod)
├── 📄 .env.docker                  # Default environment
├── 📄 .dockerignore                # Ignore for build
├── 🔧 setup.sh                     # Automated setup
├── 🔧 docker-helper.sh             # Helper commands
├── 📋 DOCKER_SETUP.md              # Quick reference
├── 📋 CODEBASE_ANALYSIS.md         # Architecture analysis
├── 📋 README.md                    # Project overview
│
├── frontend/                       # React application
│   ├── .dockerignore
│   ├── src/
│   ├── package.json
│   └── vite.config.js
│
├── backend/                        # PHP application
│   ├── .dockerignore
│   ├── config/database.php
│   ├── composer.json
│   └── index.php
│
└── database/
    └── schema.sql                  # Database initialization
```

---

## 🛠️ Development Setup

### Using Development Compose File

```bash
# Start with hot-reload
docker-compose -f docker-compose.dev.yml up -d

# Services will run at:
# - Frontend: http://localhost:3000 (with hot reload)
# - Backend: http://localhost:8000
# - MySQL: localhost:3306
# - phpMyAdmin: http://localhost:8080
```

### Frontend Development
```bash
# Frontend code changes are reflected immediately
# Edit any file in frontend/src/
# Browser will auto-refresh

# View frontend logs
docker-compose logs -f frontend
```

### Backend Development
```bash
# For PHP file changes, restart backend
docker-compose restart backend

# Debug PHP
docker-compose exec backend bash
cd /var/www/html
php -v
php -S 0.0.0.0:9000

# View backend logs
docker-compose logs -f backend
```

### Database Operations
```bash
# Access MySQL CLI
docker-compose exec db mysql -u seratif_user -pseratif_password seratif2026

# Common commands:
# SHOW TABLES;
# SELECT * FROM users;
# DESCRIBE users;

# Import SQL file
docker-compose exec -T db mysql -u seratif_user -pseratif_password seratif2026 < backup.sql

# Export database
docker-compose exec -T db mysqldump -u seratif_user -pseratif_password seratif2026 > backup.sql
```

---

## 🚢 Production Setup

### Pre-Production Checklist
- [ ] Update `.env` with production database password
- [ ] Set `APP_ENV=production`
- [ ] Configure SSL/TLS certificates
- [ ] Set up backup strategy
- [ ] Configure monitoring/logging
- [ ] Load test the application

### Production Deployment

```bash
# 1. Prepare production environment
cp .env.docker .env
# Edit .env with production values
nano .env

# 2. Use production compose file
docker-compose -f docker-compose.prod.yml build

# 3. Start services
docker-compose -f docker-compose.prod.yml up -d

# 4. Verify services are healthy
docker-compose -f docker-compose.prod.yml ps

# 5. Check logs
docker-compose -f docker-compose.prod.yml logs -f
```

### Production Nginx Configuration

Use `nginx.prod.conf` for production:
- HTTP/2 support
- Gzip compression
- Rate limiting
- Security headers
- SSL/TLS support (commented, uncomment with certs)
- Performance optimization

To use production Nginx config, update `docker-compose.prod.yml`:
```yaml
volumes:
  - ./nginx.prod.conf:/etc/nginx/nginx.conf:ro
```

### SSL/TLS Setup

```bash
# 1. Obtain SSL certificate (Let's Encrypt)
# Using Certbot:
sudo certbot certonly --standalone -d yourdomain.com

# 2. Update nginx.prod.conf with certificate paths:
# - /etc/letsencrypt/live/yourdomain.com/fullchain.pem
# - /etc/letsencrypt/live/yourdomain.com/privkey.pem

# 3. Uncomment HTTPS section in nginx.prod.conf

# 4. Restart containers
docker-compose -f docker-compose.prod.yml restart frontend
```

---

## 📚 Commands Reference

### Helper Script
```bash
# Make script executable
chmod +x docker-helper.sh

# Available commands
./docker-helper.sh start         # Start containers
./docker-helper.sh stop          # Stop containers
./docker-helper.sh restart       # Restart containers
./docker-helper.sh build         # Build images
./docker-helper.sh logs          # View all logs
./docker-helper.sh logs-backend  # Backend only
./docker-helper.sh logs-frontend # Frontend only
./docker-helper.sh logs-db       # Database only
./docker-helper.sh bash-backend  # Shell in backend
./docker-helper.sh bash-db       # MySQL CLI
./docker-helper.sh status        # Show container status
./docker-helper.sh clean         # Remove all containers
./docker-helper.sh migrate       # Run migrations
```

### Docker Compose Commands

```bash
# ===== Basic Operations =====
docker-compose up -d                 # Start services
docker-compose down                  # Stop & remove containers
docker-compose down -v               # Stop & remove with volumes
docker-compose ps                    # List services
docker-compose logs -f               # View logs (all services)
docker-compose logs -f [service]     # View logs (specific)

# ===== Building & Images =====
docker-compose build                 # Build images
docker-compose build --no-cache      # Force rebuild
docker-compose images                # List images
docker-compose pull                  # Pull latest images

# ===== Container Operations =====
docker-compose exec [service] bash   # Shell access
docker-compose exec [service] [cmd]  # Execute command
docker-compose restart [service]     # Restart service
docker-compose stop [service]        # Stop service
docker-compose start [service]       # Start service

# ===== Database =====
# Access MySQL CLI
docker-compose exec db mysql -u seratif_user -pseratif_password seratif2026

# Backup database
docker-compose exec -T db mysqldump -u seratif_user -pseratif_password seratif2026 > backup.sql

# Restore database
docker-compose exec -T db mysql -u seratif_user -pseratif_password seratif2026 < backup.sql

# ===== Cleanup =====
docker-compose down -v               # Remove all containers & volumes
docker system prune                  # Remove unused images
docker volume prune                  # Remove unused volumes
```

### Docker Commands (Without Compose)

```bash
# View running containers
docker ps

# View all containers
docker ps -a

# View images
docker images

# Execute command in container
docker exec -it [container_id] bash

# View container logs
docker logs -f [container_id]

# Stop container
docker stop [container_id]

# Remove container
docker rm [container_id]

# Remove image
docker rmi [image_id]

# View container stats
docker stats
```

---

## 🔧 Troubleshooting

### Database Connection Failed

**Problem**: Backend can't connect to database
```bash
# Check if database is running and healthy
docker-compose ps db

# Check database logs
docker-compose logs -f db

# Manually verify connection
docker-compose exec backend ping db

# Verify credentials in backend
docker-compose exec backend env | grep DB_
```

**Solution**:
```bash
# 1. Restart database
docker-compose restart db

# 2. Wait for it to be healthy (watch for "healthy" status)
docker-compose ps db

# 3. Restart backend
docker-compose restart backend

# 4. Check logs
docker-compose logs backend
```

### Frontend Blank Page

**Problem**: Frontend shows blank or 502 error
```bash
# Check frontend container
docker-compose logs -f frontend

# Check nginx config
docker-compose exec frontend nginx -t

# Check if backend is accessible
docker-compose exec frontend curl http://backend:80/
```

**Solution**:
```bash
# 1. Rebuild frontend
docker-compose build frontend

# 2. Restart services
docker-compose restart frontend backend

# 3. Check browser console for errors (F12)
# 4. Hard refresh: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)
```

### Port Already in Use

**Problem**: Error "Address already in use"
```bash
# Find process using port
sudo lsof -i :80
sudo lsof -i :8000
sudo lsof -i :3306

# Kill process
sudo kill -9 [PID]
```

**Solution**: Change ports in docker-compose.yml
```yaml
services:
  frontend:
    ports:
      - "8080:80"  # Changed from 80 to 8080
```

### PHP Errors

**Problem**: 500 Internal Server Error
```bash
# Check PHP errors
docker-compose logs -f backend

# Check file permissions
docker-compose exec backend ls -la /var/www/html/uploads/

# Test PHP
docker-compose exec backend php -r "echo 'PHP is working';"
```

**Solution**:
```bash
# Fix permissions
docker-compose exec backend chmod -R 777 /var/www/html/uploads

# Restart backend
docker-compose restart backend
```

### Out of Disk Space

```bash
# Check Docker disk usage
docker system df

# Remove unused containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Or aggressive cleanup
docker system prune -a --volumes
```

### Memory/CPU Issues

```bash
# Monitor resource usage
docker stats

# Limit resources in docker-compose.yml:
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

### Network Issues

```bash
# Check network
docker network ls
docker network inspect seratif_network

# Test connectivity between containers
docker-compose exec frontend ping backend
docker-compose exec backend ping db

# DNS issues
docker-compose exec -e DNS=1.1.1.1 backend curl https://api.github.com
```

---

## 📊 Monitoring

### View Logs
```bash
# Real-time logs from all services
docker-compose logs -f

# Last 100 lines from backend
docker-compose logs --tail=100 backend

# Search logs for errors
docker-compose logs backend | grep -i error

# Timestamp logs
docker-compose logs -f --timestamps backend
```

### Health Checks
```bash
# All services must show "Up (healthy)"
docker-compose ps

# Manual health check
docker-compose exec frontend curl http://localhost/health
docker-compose exec backend curl http://localhost:80/
```

### Performance Metrics
```bash
# Real-time stats
docker stats

# Specific container
docker stats seratif_backend

# Format output
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

---

## 🔐 Security Best Practices

### 1. Environment Variables
```bash
# Use strong passwords in .env
DB_PASS=YourStrongPassword123!@#
DB_ROOT_PASS=SuperSecureRootPassword456!@#
```

### 2. Database Backups
```bash
# Regular backups
0 2 * * * docker-compose exec -T db mysqldump -u seratif_user -pseratif_password seratif2026 > /backup/seratif2026_$(date +\%Y\%m\%d_\%H\%M\%S).sql
```

### 3. SSL/TLS
```bash
# Always use HTTPS in production
# Get certificate from Let's Encrypt
certbot certonly --standalone -d yourdomain.com
```

### 4. Network Isolation
```bash
# Database port NOT exposed in production
# Modify docker-compose.prod.yml:
services:
  db:
    ports: []  # Don't expose port 3306
```

### 5. Regular Updates
```bash
# Keep images updated
docker-compose pull
docker-compose build --pull
```

---

## 🚀 Performance Optimization

### Frontend
- ✅ Gzip compression enabled
- ✅ Static asset caching (1 year)
- ✅ Nginx minification
- ✅ SPA routing optimization

### Backend
- ✅ Apache MPM settings optimized
- ✅ PHP-FPM available (future upgrade)
- ✅ Prepared statements for queries
- ✅ Connection pooling ready

### Database
- ✅ Indexes on commonly searched fields
- ✅ UTF8MB4 charset
- ✅ InnoDB engine (ACID compliance)

### Scaling
```yaml
# For multiple backend instances:
version: '3.8'
services:
  backend:
    deploy:
      replicas: 3  # Run 3 instances
```

---

## 📞 Support & Resources

### Documentation Files
- [DOCKER_SETUP.md](./DOCKER_SETUP.md) - Quick setup guide
- [CODEBASE_ANALYSIS.md](./CODEBASE_ANALYSIS.md) - Architecture analysis
- [README.md](./README.md) - Project overview

### Useful Links
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [PHP Docker Hub](https://hub.docker.com/_/php)
- [MySQL Docker Hub](https://hub.docker.com/_/mysql)

### Getting Help
```bash
# Docker version info
docker --version
docker-compose --version

# System information
docker system info

# Detailed error messages
docker-compose logs -f [service] | grep -i error
```

---

## ✨ Tips & Tricks

### Quick Database Reset
```bash
docker-compose down -v
docker-compose up -d
sleep 30
# Database will be re-initialized from schema.sql
```

### Backup & Restore
```bash
# Create backup
docker-compose exec -T db mysqldump -u seratif_user -pseratif_password seratif2026 > backup.sql

# Restore from backup
docker-compose exec -T db mysql -u seratif_user -pseratif_password seratif2026 < backup.sql
```

### View Database Tables
```bash
docker-compose exec db mysql -u seratif_user -pseratif_password seratif2026 -e "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='seratif2026';"
```

### Check Container Disk Usage
```bash
# Find largest containers
docker exec $(docker ps -q) du -sh /* 2>/dev/null | sort -rh | head -5
```

---

*Last Updated: 2026-02-23*
*Seratif 2026 - Ticketing System*
*Docker Version: 3.8+ | Docker Desktop: 4.0+*
