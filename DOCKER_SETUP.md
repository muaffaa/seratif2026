# 🐳 Docker Setup - Seratif 2026

## Analisis Codebase

### Stack Teknologi
- **Frontend**: React 19 + Vite + Tailwind CSS
- **Backend**: PHP 8.1 + Apache + Composer
- **Database**: MySQL 8.0
- **QR Code**: Endroid QR Code Library
- **PDF**: TCPDF Library

### Struktur Aplikasi
```
seratif2026/
├── frontend/          # React SPA (Vite)
│   ├── src/
│   ├── public/
│   └── package.json
├── backend/           # PHP API
│   ├── api/          # Endpoints
│   ├── auth/         # Authentication
│   ├── admin/        # Admin panel
│   ├── config/       # Database config
│   └── composer.json
└── database/         # MySQL schema
```

## Prerequisites

- Docker Desktop (https://www.docker.com/products/docker-desktop)
- Docker Compose v3.8+
- Minimal 2GB RAM untuk Docker

## Quick Start

### 1. Clone/Setup Repository
```bash
cd /home/muaffaa/Documents/myRepo/seratif2026
```

### 2. Konfigurasi Environment
```bash
# Copy env example
cp .env.docker .env

# Edit jika perlu (opsional)
nano .env
```

### 3. Build & Run Containers
```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# Check status
docker-compose ps
```

### 4. Inisialisasi Database
```bash
# Database akan otomatis initialize dari schema.sql
# Tunggu ~30 detik sampai db sehat

# Verify koneksi database
docker-compose exec db mysql -u seratif_user -pseratif_password seratif2026 -e "SELECT COUNT(*) FROM users;"
```

### 5. Access Aplikasi
- **Frontend**: http://localhost
- **Backend API**: http://localhost:8000
- **phpMyAdmin**: http://localhost:8080
  - User: `seratif_user`
  - Password: `seratif_password`

## Common Commands

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

### Database Access
```bash
# MySQL CLI
docker-compose exec db mysql -u seratif_user -pseratif_password seratif2026

# phpMyAdmin
# http://localhost:8080
```

### Backend Console
```bash
docker-compose exec backend bash
cd /var/www/html
php -r "require 'vendor/autoload.php'; echo 'PHP OK';"
```

### Rebuild After Code Changes
```bash
# Backend changes (PHP)
docker-compose build backend
docker-compose up -d backend

# Frontend changes (React)
docker-compose build frontend
docker-compose up -d frontend
```

### Clean Up
```bash
# Stop dan remove containers
docker-compose down

# Remove volumes juga (hati-hati, akan delete database!)
docker-compose down -v

# Remove images
docker rmi seratif2026_backend seratif2026_frontend
```

## Troubleshooting

### Database Connection Error
```bash
# Check db container logs
docker-compose logs db

# Verify db is healthy
docker-compose ps db

# Manually check connection
docker-compose exec backend curl http://db:3306
```

### Frontend not loading
```bash
# Check frontend logs
docker-compose logs -f frontend

# Check nginx config
docker-compose exec frontend nginx -t
```

### Backend 500 error
```bash
# Check PHP errors
docker-compose logs -f backend

# Check file permissions
docker-compose exec backend ls -la /var/www/html/uploads/
```

### Port already in use
```bash
# Find what's using port 80
sudo lsof -i :80

# Change port di docker-compose.yml
# Ubah "80:80" menjadi "8080:80" untuk frontend
```

## Environment Variables

Edit `.env` untuk customize:

```env
# Database
DB_HOST=db
DB_NAME=seratif2026
DB_USER=seratif_user
DB_PASS=seratif_password

# Application
APP_ENV=production
APP_URL=http://localhost

# Ports (ubah sesuai kebutuhan)
NGINX_PORT=80
BACKEND_PORT=8000
```

## Production Deployment Notes

Untuk production, pertimbangkan:

1. **Environment**: Ubah APP_ENV ke `production`
2. **Database Password**: Gunakan password yang kuat
3. **SSL/HTTPS**: Tambahkan SSL certificate di Nginx
4. **Volumes**: Mount uploads ke persistent storage
5. **Resources**: Set CPU/Memory limits di docker-compose
6. **Backup**: Setup automatic database backups
7. **Monitoring**: Tambahkan health checks dan logging

## File Structure

```
docker-compose.yml      # Main orchestration file
Dockerfile.backend      # PHP/Apache container
Dockerfile.frontend     # Node/Nginx container
nginx.conf             # Nginx configuration
.env.docker            # Environment variables
.dockerignore          # Files excluded dari build
DOCKER_SETUP.md        # Dokumentasi ini
```

## Performance Tips

1. **Caching**:
   ```bash
   docker-compose build --no-cache backend
   ```

2. **Resource Limits** (docker-compose.yml):
   ```yaml
   services:
     backend:
       deploy:
         resources:
           limits:
             cpus: '1'
             memory: 512M
   ```

3. **Volume Optimization**:
   - Gunakan named volumes untuk database
   - Bind mounts hanya untuk development

## Security Best Practices

- ✅ Non-root users di containers
- ✅ Health checks untuk all services
- ✅ Security headers di Nginx
- ✅ Database password di environment variables
- ⚠️ TODO: Tambahkan reverse proxy (Traefik/Nginx-proxy)
- ⚠️ TODO: Implementasi SSL/TLS
- ⚠️ TODO: Rate limiting
- ⚠️ TODO: CORS configuration

## Next Steps

1. **Testing**: Setup testing di containers
   ```bash
   docker-compose exec backend phpunit
   ```

2. **CI/CD**: Integrate dengan GitHub Actions/GitLab CI
   ```yaml
   - docker-compose build
   - docker-compose up -d
   - docker-compose exec -T db mysql -u...
   ```

3. **Scaling**: Gunakan Docker Swarm atau Kubernetes untuk multiple instances

## Support

Untuk issues atau questions:
- Check logs: `docker-compose logs -f`
- Verify status: `docker-compose ps`
- Rebuild: `docker-compose build --no-cache`

---
Generated: 2026-02-23
Version: 1.0
