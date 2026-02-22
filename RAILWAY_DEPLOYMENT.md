# Railway Deployment Guide - Seratif 2026

## 📍 What is Railway?

Railway is a modern cloud platform that makes deploying applications simple and affordable.

**Benefits:**
- ✅ Free tier for testing
- ✅ Easy Docker deployment
- ✅ Built-in database support (MySQL, PostgreSQL)
- ✅ Environment variables management
- ✅ Automatic deployments from Git
- ✅ Public URLs with custom domains
- ✅ No credit card required to start

**Pricing:** Pay-per-use (very affordable)

---

## 🚀 Quick Deploy to Railway (5 minutes)

### Step 1: Create Railway Account
1. Go to https://railway.app
2. Sign up with GitHub (recommended)
3. Authorize Railway

### Step 2: Create New Project
1. Click "New Project"
2. Select "Deploy from GitHub"
3. Connect your GitHub account
4. Select the `seratif2026` repository
5. Click "Deploy"

### Step 3: Configure Services

Railway will detect the Dockerfile. Configure:

**Frontend Service:**
- Port: 80
- Name: `frontend`

**Backend Service:**
- Port: 8000
- Name: `backend`

**Database Service:**
- Add MySQL 8.0
- Database name: `seratif2026`

### Step 4: Set Environment Variables

In Railway Dashboard → Project Settings → Variables:

```env
# Database
DB_HOST=mysql
DB_PORT=3306
DB_NAME=seratif2026
DB_USER=seratif_user
DB_PASS=your_strong_password_here
DB_ROOT_PASS=your_strong_root_password

# Application
APP_ENV=production
APP_URL=https://your-domain.railway.app

# Frontend
VITE_API_URL=https://your-domain.railway.app
```

### Step 5: Deploy
- Push to your GitHub repository
- Railway automatically deploys
- Get your public URL from Railway Dashboard

---

## 🐳 Docker Deployment (Recommended)

### Option A: Using Railway CLI

```bash
# 1. Install Railway CLI
npm i -g @railway/cli

# 2. Login to Railway
railway login

# 3. Initialize Railway project
railway init

# 4. Configure services
railway add
# Select: MySQL
# Select: Docker

# 5. Set environment variables
railway variables set DB_HOST mysql
railway variables set DB_NAME seratif2026
railway variables set DB_USER seratif_user
railway variables set DB_PASS your_password

# 6. Deploy
railway up
```

### Option B: Using Railway Dashboard (GUI)

1. Go to https://railway.app/dashboard
2. Create new project
3. Add services:
   - **Docker** (Frontend from Dockerfile.frontend)
   - **Docker** (Backend from Dockerfile.backend)
   - **MySQL** (Database)
4. Configure each service
5. Set environment variables
6. Deploy

---

## 📋 Complete Railway Setup

### Prerequisites
- GitHub account (for Git integration)
- Railway account (free at https://railway.app)
- Docker images already built locally

### Step-by-Step Setup

#### 1. Prepare Railway Configuration

Create `Procfile` (tells Railway how to start):

```
web: nginx -g "daemon off;"
api: php -S 0.0.0.0:8000 -t /var/www/html
```

#### 2. Configure Database

Railway will provide MySQL connection string:
```
mysql://seratif_user:password@rail.internal:3306/seratif2026
```

Parse this to environment variables:
- `DB_HOST=rail.internal`
- `DB_PORT=3306`
- `DB_NAME=seratif2026`
- `DB_USER=seratif_user`
- `DB_PASS=password`

#### 3. Set Up Environment Variables

In Railway Dashboard → Project → Variables:

```env
# Database Configuration
DB_HOST=mysql
DB_PORT=3306
DB_NAME=seratif2026
DB_USER=seratif_user
DB_PASS=${MYSQL_PASSWORD}
DB_ROOT_PASS=${MYSQL_ROOT_PASSWORD}

# Application Configuration
APP_ENV=production
APP_URL=https://${RAILWAY_PUBLIC_DOMAIN}
NODE_ENV=production
PORT=8000

# Frontend Configuration
VITE_API_URL=https://${RAILWAY_PUBLIC_DOMAIN}
REACT_APP_API_URL=https://${RAILWAY_PUBLIC_DOMAIN}
```

#### 4. Create Railway Configuration

Create `railway.json`:

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE"
  },
  "deploy": {
    "startCommand": "npm run build && npm run start",
    "restartPolicyCondition": "on-failure",
    "restartPolicyMaxRetries": 5
  }
}
```

#### 5. Deploy Services

**Option 1: From Docker Hub**
```bash
railway add docker
# Input: muaffaa/seratif2026-frontend:latest
railway add docker
# Input: muaffaa/seratif2026-backend:latest
railway add mysql
```

**Option 2: From GitHub**
1. Connect GitHub repository
2. Railway auto-detects Dockerfile
3. Builds and deploys automatically

#### 6. Configure Each Service

**Frontend Service:**
```yaml
Port: 80
Dockerfile: Dockerfile.frontend
Environment:
  - VITE_API_URL=https://your-app.railway.app
```

**Backend Service:**
```yaml
Port: 8000
Dockerfile: Dockerfile.backend
Environment:
  - DB_HOST=mysql
  - DB_NAME=seratif2026
  - DB_USER=seratif_user
  - DB_PASS=${MYSQL_PASSWORD}
```

**Database Service:**
```yaml
Type: MySQL 8.0
Database: seratif2026
User: seratif_user
Auto-backup: enabled
```

#### 7. Connect Services

In Railway:
1. Go to service configuration
2. Add service dependency
3. Backend → requires → MySQL
4. Frontend → requires → Backend

#### 8. Deploy

```bash
git push origin main
# Railway automatically deploys
```

Check deployment status in Railway Dashboard.

---

## 🔗 Domain Configuration

### Add Custom Domain

1. Go to Railway Dashboard → Project
2. Select Frontend service
3. Click "Domains"
4. Add custom domain
5. Configure DNS:
   ```
   CNAME: your-domain.com → railway.app
   ```

### Get Public URL

Railway provides:
- Default URL: `https://seratif2026-production.up.railway.app`
- Custom domain: `https://your-domain.com`

Update all references:
- Frontend `.env`: `VITE_API_URL=https://your-domain.com`
- Backend `.env`: `APP_URL=https://your-domain.com`

---

## 🔐 Security for Railway

### Environment Variables
- Store all secrets in Railway variables
- Never commit secrets to Git
- Use strong passwords (20+ chars)

### Database Security
- Railway provides secure connection
- Use `rail.internal` for internal connections
- Regular automated backups

### SSL/TLS
- Railway provides free HTTPS
- Auto-renews certificates
- Enforces HTTPS redirects

### Firewall
- Only Railway services can access database
- Database not exposed to internet
- Private networking between services

---

## 📊 Railway vs Docker Compose

| Feature | Docker Compose | Railway |
|---------|---|---|
| Local Development | ✅ Best | ❌ Not suited |
| Production | ⚠️ Manual | ✅ Best |
| Database Backup | ❌ Manual | ✅ Automatic |
| Scaling | ⚠️ Complex | ✅ Easy |
| Cost | 🎉 Free (self-hosted) | 💰 Pay-per-use |
| Monitoring | ❌ Manual setup | ✅ Built-in |
| Deployment | ❌ Manual SSH | ✅ Automatic Git |

**Recommendation:**
- Use **Docker Compose locally** for development
- Use **Railway for production** deployment

---

## 🚢 Deployment Strategy

### Development Workflow
```
Local (Docker Compose)
    ↓
Git commit & push
    ↓
GitHub repository
    ↓
Railway auto-deploys
    ↓
Production at railway.app
```

### Steps:
1. Development locally with `docker-compose up -d`
2. Test everything
3. Commit changes: `git commit -m "feat: ..."`
4. Push to GitHub: `git push origin main`
5. Railway automatically builds and deploys
6. Monitor at Railway Dashboard

---

## 📈 Monitoring & Logs

### View Logs in Railway

```bash
# Using Railway CLI
railway logs

# Using Dashboard
# Go to: Project → Service → Logs
```

### Common Issues

**Database connection error:**
```bash
# Check Railway database is running
railway logs -s mysql

# Verify connection string
# Format: mysql://user:pass@rail.internal:3306/database
```

**Frontend showing blank page:**
```bash
# Check frontend logs
railway logs -s frontend

# Verify API_URL is correct
# Should be: https://your-domain.railway.app
```

**Backend 500 error:**
```bash
# Check backend logs
railway logs -s backend

# Check database connectivity
railway run mysql -u seratif_user -p seratif2026
```

---

## 🎯 Railway vs Other Platforms

| Platform | Ease | Cost | Support | Best For |
|----------|------|------|---------|----------|
| Railway | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | Quick deployment |
| Heroku | ⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐ | Simple apps |
| AWS | ⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | Enterprise |
| Docker Compose | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | Self-hosted |
| DigitalOcean | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | VPS deployment |

**Why Railway for Seratif 2026:**
- ✅ Easy Git integration
- ✅ Affordable pricing
- ✅ Built-in MySQL support
- ✅ Automatic deployments
- ✅ Free HTTPS
- ✅ Good uptime SLA

---

## 💡 Production Checklist

- [ ] Create Railway account
- [ ] Connect GitHub repository
- [ ] Configure MySQL database
- [ ] Set environment variables
- [ ] Configure custom domain
- [ ] Test frontend access
- [ ] Test backend API
- [ ] Check database connectivity
- [ ] Enable automated backups
- [ ] Monitor logs for errors
- [ ] Setup alerting (if available)
- [ ] Document deployment process

---

## 🔄 Redeployment & Updates

### Automatic Redeployment
```bash
# Just push to main branch
git commit -m "fix: bug fix"
git push origin main
# Railway automatically rebuilds and deploys
```

### Manual Redeploy
```bash
# Using Railway CLI
railway up

# Or use Dashboard
# Project → Service → Redeploy
```

### Rollback to Previous Version
```bash
# Railway keeps deployment history
# Dashboard → Project → Deployments
# Click "Redeploy" on previous version
```

---

## 🆘 Troubleshooting

### Deployment Fails
```
Check:
1. Dockerfile is correct
2. No secret credentials in code
3. Environment variables set
4. Database is running
```

### App won't start
```
Check:
1. PORT environment variable (should be 8000)
2. Database connection string
3. All required dependencies installed
4. No syntax errors in code
```

### Database not accessible
```
Check:
1. MySQL service is running
2. DB_HOST is set to 'mysql' (Railway internal DNS)
3. DB_USER and DB_PASS are correct
4. Database initialized with schema
```

### Slow performance
```
Check:
1. View Railway metrics
2. Check database query performance
3. Increase instance size if needed
4. Enable caching
```

---

## 📚 Railway Resources

### Official Links
- [Railway Docs](https://docs.railway.app)
- [Railway Templates](https://railway.app/templates)
- [Railway GitHub](https://github.com/railwayapp)

### Helpful Guides
- [Deploy Docker Container](https://docs.railway.app/deploy/dockerfiles)
- [Environment Variables](https://docs.railway.app/develop/variables)
- [MySQL Setup](https://docs.railway.app/databases/mysql)
- [Custom Domains](https://docs.railway.app/develop/domains)

### Community
- [Railway Discord](https://discord.gg/railway)
- [Railway Status](https://status.railway.app)

---

## 🎉 Quick Deploy Summary

```bash
# 1. Create Railway account
# 2. Connect GitHub repository
# 3. Add services:
#    - Frontend (Dockerfile.frontend)
#    - Backend (Dockerfile.backend)
#    - MySQL 8.0
# 4. Set environment variables
# 5. Deploy
# 6. Access at provided Railway URL
```

**That's it!** Your Seratif 2026 is live on Railway 🚀

---

## ⚡ Next Steps

1. **Create Railway Account**: https://railway.app
2. **Connect GitHub**: Authorize Railway
3. **Deploy**: Follow dashboard prompts
4. **Configure Domain**: Add custom domain
5. **Monitor**: Watch logs and metrics

---

*Last Updated: 2026-02-23*
*Seratif 2026 - Railway Deployment Guide*
