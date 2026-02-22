# 🚀 Panduan Deploy Seratif 2026 ke Railway - STEP BY STEP

## 📍 Apa itu Railway?

Railway adalah platform cloud modern yang membuat deploy aplikasi sangat mudah. Cocok untuk Seratif 2026!

**Keuntungan Railway:**
- ✅ Deploy dari GitHub (auto-deploy setiap push)
- ✅ Database MySQL terintegrasi
- ✅ Free tier untuk testing
- ✅ Harga terjangkau (pay-per-use)
- ✅ HTTPS otomatis
- ✅ Support Tim yang responsif

**Estimasi Biaya:** $5-20/bulan untuk aplikasi production-ready

---

## ⚡ QUICK START (5 Menit)

Jika Anda ingin langsung deploy tanpa banyak pertanyaan:

### Step 1: Siapkan Repository GitHub
```bash
cd /home/muaffaa/Documents/myRepo/seratif2026

# Inisialisasi Git (jika belum)
git init

# Add semua file
git add .

# Commit
git commit -m "Initial commit: Seratif 2026 with Docker"

# Push ke GitHub (pastikan sudah ada remote)
git push origin main
```

### Step 2: Buat Railway Account
1. Buka https://railway.app
2. Click "Start Free" atau "Sign Up"
3. Pilih "Sign up with GitHub"
4. Authorize Railway

### Step 3: Deploy
1. Di Railway Dashboard, click "New Project"
2. Pilih "Deploy from GitHub"
3. Authorize akses ke repository
4. Pilih `seratif2026`
5. Click "Deploy"

### Step 4: Tunggu Deployment
Railway akan:
- ✓ Build aplikasi
- ✓ Setup database
- ✓ Deploy otomatis

**Durasi: 5-10 menit**

### Step 5: Akses Aplikasi
- Buka URL yang diberikan Railway (contoh: `https://seratif2026-production.up.railway.app`)
- Aplikasi siap digunakan!

---

## 🎯 STEP-BY-STEP LENGKAP (Dengan Screenshots)

### TAHAP 1: Persiapan (15 menit)

#### 1.1 Pastikan GitHub Repository Siap

```bash
# Navigasi ke project
cd /home/muaffaa/Documents/myRepo/seratif2026

# Check status git
git status

# Jika belum initialized
git init
git remote add origin https://github.com/USERNAME/seratif2026.git

# Add semua file ke git
git add .

# Commit dengan pesan yang jelas
git commit -m "feat: Add complete Docker setup and Railway configuration"

# Push ke GitHub
git push -u origin main
```

**Hasil yang Diharapkan:**
- ✅ Semua file terupload ke GitHub
- ✅ Repository bisa diakses di https://github.com/USERNAME/seratif2026
- ✅ File Docker dan Dockerfile terlihat

#### 1.2 Verifikasi File Penting

Railway akan mencari file-file ini:
- ✅ `Dockerfile.backend` - untuk backend
- ✅ `Dockerfile.frontend` - untuk frontend
- ✅ `docker-compose.yml` - orchestration
- ✅ `.env.railway` - template environment
- ✅ `railway.json` - konfigurasi Railway
- ✅ `Procfile` - proses startup

Pastikan semua ada di repository!

```bash
# Verify files exist
ls -la Dockerfile* docker-compose.yml .env.railway railway.json Procfile
```

---

### TAHAP 2: Setup Railway (10 menit)

#### 2.1 Create Railway Account

1. **Buka https://railway.app**
   
2. **Click "Start Free"**
   
3. **Login dengan GitHub**
   - Click "Sign up with GitHub"
   - Authorize Railway untuk akses repository
   - Accept terms

4. **Verifikasi Email** (jika diminta)

**Hasil:**
- ✅ Railway account active
- ✅ Dashboard accessible
- ✅ Ready to create project

#### 2.2 Create New Project

1. **Go to Dashboard** (https://railway.app/dashboard)

2. **Click "New Project"**

3. **Select "Deploy from GitHub"**

4. **Authorize GitHub Access**
   - Click "Connect GitHub"
   - Select repository: `seratif2026`
   - Click "Authorize"

5. **Select Repository**
   - Filter: `seratif2026`
   - Click to select

6. **Click "Deploy Now"**

Railway akan mulai building!

**Hasil:**
- ✅ Project dibuat
- ✅ Build process started
- ✅ Services being created

---

### TAHAP 3: Konfigurasi Services (15 menit)

Railway auto-detect Dockerfile. Sekarang konfigurasi setiap service:

#### 3.1 Frontend Service

1. **Go to Project → Services**

2. **Find "frontend" service**

3. **Click to configure**

4. **Set Environment Variables:**
   ```
   PORT=80
   NODE_ENV=production
   VITE_API_URL=https://[RAILWAY_DOMAIN]
   ```

5. **Configure Build:**
   - Dockerfile: `Dockerfile.frontend`
   - Build Directory: `/`

6. **Configure Deploy:**
   - Port: `80`
   - Restart Policy: `on-failure`

7. **Save & Deploy**

#### 3.2 Backend Service

1. **Find "backend" service**

2. **Click to configure**

3. **Set Environment Variables:**
   ```
   PORT=8000
   DB_HOST=mysql
   DB_NAME=seratif2026
   DB_USER=seratif_user
   DB_PASS=[GENERATE_STRONG_PASSWORD]
   APP_ENV=production
   APP_URL=https://[RAILWAY_DOMAIN]
   ```

4. **Configure Build:**
   - Dockerfile: `Dockerfile.backend`
   - Build Directory: `/`

5. **Configure Deploy:**
   - Port: `8000`
   - Health Check: `/`

6. **Save & Deploy**

#### 3.3 Database Service

1. **Click "Add Service"**

2. **Select "Database"**

3. **Choose "MySQL 8.0"**

4. **Configure:**
   - Database Name: `seratif2026`
   - Root Password: [GENERATE_STRONG_PASSWORD]
   - Username: `seratif_user`
   - Password: [GENERATE_STRONG_PASSWORD]

5. **Create Database**

6. **Note Connection Details:**
   - HOST: `mysql.internal` atau `mysql`
   - PORT: `3306`
   - DATABASE: `seratif2026`
   - USER: `seratif_user`
   - PASSWORD: [yang tadi]

---

### TAHAP 4: Set Environment Variables (10 menit)

Environment variables sangat penting untuk production!

#### 4.1 Buka Variable Manager

1. **Project → Settings → Environment**

2. **Add Variables untuk semua services:**

**Frontend Variables:**
```
PORT=80
NODE_ENV=production
VITE_API_URL=https://seratif2026-production.up.railway.app
REACT_APP_API_URL=https://seratif2026-production.up.railway.app
```

**Backend Variables:**
```
PORT=8000
APP_ENV=production
DB_HOST=mysql
DB_PORT=3306
DB_NAME=seratif2026
DB_USER=seratif_user
DB_PASS=[strong_password]
APP_URL=https://seratif2026-production.up.railway.app
```

**Database Variables:**
```
MYSQL_ROOT_PASSWORD=[strong_password]
MYSQL_DATABASE=seratif2026
MYSQL_USER=seratif_user
MYSQL_PASSWORD=[strong_password]
```

#### 4.2 Best Practices untuk Secrets

**JANGAN PERNAH:**
- ❌ Commit passwords ke Git
- ❌ Gunakan password default
- ❌ Share credentials di email

**HARUS:**
- ✅ Generate strong passwords (20+ chars)
- ✅ Store di Railway Variables
- ✅ Rotate regularly

**Cara Generate Strong Password:**
```bash
openssl rand -base64 32
# atau
head -c 32 /dev/urandom | base64
```

---

### TAHAP 5: Deploy & Monitor (10 menit)

#### 5.1 Trigger Deployment

**Option A: Auto (Recommended)**
```bash
# Push ke GitHub, Railway auto-deploy
git commit -m "Production ready"
git push origin main
```

**Option B: Manual dari Dashboard**
1. Project → [Service] → Redeploy
2. Click "Redeploy"
3. Wait untuk build selesai

#### 5.2 Monitor Build Progress

1. **Go to Project → Deployments**

2. **Watch build log:**
   - ✓ Building image
   - ✓ Pushing to registry
   - ✓ Deploying container
   - ✓ Running health checks

3. **Status should show:**
   - 🟢 Green = Running
   - 🔴 Red = Failed
   - 🟡 Yellow = Building

#### 5.3 Check Logs for Errors

```bash
# Menggunakan Railway CLI
railway logs

# Atau dari Dashboard
# Project → [Service] → Logs
```

**Typical Logs:**
```
✓ Starting Apache web server...
✓ Loading PHP modules...
✓ Connecting to database...
✓ Server running on port 8000
```

---

### TAHAP 6: Access Your Application (5 menit)

#### 6.1 Get Public URL

1. **Go to Project → Deployments**

2. **Find your service**

3. **Copy Public URL:**
   - Frontend: `https://seratif2026-production.up.railway.app`
   - Backend: `https://seratif2026-production.up.railway.app:8000`

#### 6.2 Test Application

```bash
# Test frontend
curl -I https://seratif2026-production.up.railway.app
# Should return: 200 OK

# Test backend
curl https://seratif2026-production.up.railway.app:8000
# Should return: 200 OK or Apache info

# Test database connection (from backend)
# Backend logs should show: "Database connected"
```

#### 6.3 Access in Browser

1. **Frontend:**
   ```
   https://seratif2026-production.up.railway.app
   ```

2. **phpMyAdmin (optional):**
   ```
   Need to expose via backend or separate service
   ```

---

### TAHAP 7: Setup Custom Domain (Optional, 10 menit)

Jika ingin domain sendiri (contoh: ticketing.mycompany.com)

#### 7.1 Add Custom Domain

1. **Project → [Frontend Service] → Domains**

2. **Click "Add Domain"**

3. **Enter custom domain:**
   ```
   ticketing.mycompany.com
   ```

4. **Get DNS Target:**
   Railway akan memberikan CNAME target

#### 7.2 Configure DNS

Go to domain registrar (GoDaddy, Namecheap, etc):

1. **Add CNAME record:**
   ```
   Name: ticketing
   Target: seratif2026-production.up.railway.app
   TTL: 3600
   ```

2. **Wait 24-48 hours untuk propagation**

3. **Verify:**
   ```bash
   nslookup ticketing.mycompany.com
   # Should resolve to Railway IP
   ```

#### 7.3 Update API URLs

Update di Railway Variables:
```
APP_URL=https://ticketing.mycompany.com
VITE_API_URL=https://ticketing.mycompany.com
```

---

## 🎯 Post-Deployment Checklist

- [ ] Aplikasi accessible via public URL
- [ ] Frontend loads correctly
- [ ] Backend API responding
- [ ] Database connected
- [ ] Logs showing no errors
- [ ] SSL/HTTPS working
- [ ] Environment variables set
- [ ] Domain configured (optional)
- [ ] Backups enabled
- [ ] Monitoring setup

---

## 🔧 Troubleshooting

### Build Failed
```
Check:
1. Dockerfile syntax correct
2. All dependencies in Dockerfile
3. Build doesn't require user input
4. Review build logs for errors
```

### Application won't start
```
Check:
1. Port environment variable set
2. Database connection string correct
3. All env vars are set
4. Check application logs
```

### Can't connect to database
```
Check:
1. MySQL service is running (green status)
2. DB_HOST is 'mysql' (Railway internal DNS)
3. Credentials match database service
4. Network access allows connection
```

### Slow performance
```
Check:
1. Review Railway metrics
2. Check database queries
3. Optimize slow queries
4. Consider upgrading instance size
```

---

## 📈 Monitoring & Maintenance

### Daily
- Check application logs for errors
- Monitor database size
- Verify uptime

### Weekly
- Review resource usage
- Check for failed deployments
- Test backup restore

### Monthly
- Update dependencies
- Review security logs
- Optimize performance
- Test disaster recovery

---

## 💡 Tips untuk Production

1. **Enable Backups:**
   - Railway → MySQL → Backups
   - Set automatic backups daily

2. **Monitor Logs:**
   - Set up log aggregation
   - Configure alerts for errors
   - Review error trends

3. **Update Regularly:**
   - Keep dependencies updated
   - Apply security patches
   - Test in staging first

4. **Document Everything:**
   - Connection strings
   - Backup procedures
   - Emergency contacts
   - Deployment process

---

## 🚀 Next Deployments (Setelah Deploy Pertama)

**Workflow untuk update:**

```bash
# 1. Make changes locally
# 2. Test with Docker
docker-compose up -d

# 3. Commit dan push
git add .
git commit -m "fix: update feature"
git push origin main

# 4. Railway auto-deploys!
# Monitor at dashboard
```

**Selesai!** No SSH, no manual server access needed.

---

## 📞 Support & Resources

### Railway Docs
- https://docs.railway.app
- https://docs.railway.app/deploy/dockerfiles
- https://docs.railway.app/databases/mysql

### Common Issues
- https://docs.railway.app/troubleshooting
- https://discord.gg/railway (Community)

### Tools
- Railway CLI: `npm i -g @railway/cli`
- Health Checks: Built-in
- Logs: Real-time in dashboard

---

## ✅ Summary

**Langkah Utama:**
1. Prepare GitHub repository ✓
2. Create Railway account ✓
3. Deploy from GitHub ✓
4. Configure services ✓
5. Set environment variables ✓
6. Monitor deployment ✓
7. Access aplikasi ✓

**Total waktu:** 30-45 menit (pertama kali)

**Setelah itu:** Deploy baru hanya dengan `git push`!

---

**Status:** ✅ Ready to Deploy
**Updated:** 2026-02-23
**Support:** Check RAILWAY_DEPLOYMENT.md untuk detail lengkap
