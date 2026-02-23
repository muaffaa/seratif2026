# Railway Deployment Guide - Seratif2026

## Current Status
✅ **Application Deployed**: https://seratif2026-production.up.railway.app

## What's Done
- ✅ Frontend (React) built and deployed
- ✅ Backend (PHP) deployed  
- ✅ Docker container running
- ✅ Code on GitHub

## What's Needed - Database Setup

### Step 1: Add MySQL to Railway Project
1. Open Railway Dashboard: https://railway.app
2. Go to `seratif2026` project
3. Click "New" → Select "MySQL"
4. Wait for MySQL to provision
5. Copy the connection details

### Step 2: Configure Environment Variables
In Railway Dashboard, go to `seratif2026` service → Variables, add:

```
DB_HOST=<mysql_host_from_railway>
DB_NAME=seratif2026
DB_USER=<mysql_user>
DB_PASS=<mysql_password>
DB_PORT=3306
```

### Step 3: Run Database Schema
After MySQL is ready, execute the schema in your Railway MySQL:

```bash
# Download schema.sql from repository
# Import via Railway MySQL admin interface or MySQL CLI:
mysql -h <host> -u <user> -p<password> seratif2026 < database/schema.sql
```

### Step 4: Redeploy Application
Once database is configured, the app will automatically connect.

## Local Development Testing

### Start Backend
```bash
./start-backend.sh
# Server runs on http://localhost:8000
```

### Start Frontend
```bash
cd frontend
npm run dev
# App runs on http://localhost:5173
```

### Database
- Ensure MySQL is running locally
- Default credentials in `start-backend.sh`:
  - Host: localhost
  - User: root
  - Password: admin123
  - Database: seratif2026

## API Endpoints Available
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `GET /user/status` - Check user session
- `POST /upload-payment` - Upload payment proof
- `GET /admin/payments` - List all payments (admin)
- `POST /admin/login` - Admin login
- `POST /admin/approve` - Approve payment (admin)
- `GET /ticket/{uuid}` - Get ticket details
- `GET /validate/{uuid}` - Validate ticket

## Health Check
```bash
curl https://seratif2026-production.up.railway.app/health
```

Response:
```json
{"status":"ok","db_host":"localhost"}
```

## Troubleshooting

### 502 Bad Gateway
- Check MySQL is running in Railway
- Verify environment variables are set correctly
- Check Railway logs: `railway logs`

### Database Connection Error
- Confirm DB_HOST is correct (Railway provides full hostname)
- Check DB_USER and DB_PASS
- Ensure database `seratif2026` exists

### CORS Issues
- Frontend and backend are on same domain in production
- CORS headers automatically set in `backend/router.php`

## Support
For detailed issues, check Railway dashboard logs or GitHub issues.
