# 🔍 SERATIF2026 - COMPREHENSIVE CODE ANALYSIS

## 📊 Project Overview

### Architecture
- **Frontend**: React 19 + Vite + React Router + TailwindCSS
- **Backend**: PHP 8.2 with built-in server
- **Database**: MySQL 8.0
- **Deployment**: Docker (Alpine Linux) → Railway

---

## ⚙️ BACKEND ANALYSIS

### Structure
```
backend/
├── index.php              ← Main router (handles all requests)
├── router.php             ← Docker router (bridges backend & frontend)
├── auth/
│   ├── login.php
│   ├── logout.php
│   └── register.php
├── admin/
│   ├── login.php
│   └── payments.php
├── api/
│   ├── ticket.php
│   ├── upload_payment.php
│   ├── user_status.php
│   └── validate.php
├── config/
│   └── database.php       ← PDO connection
├── utils/
│   └── helpers.php
└── vendor/                ← Composer packages (QR, TCPDF)
```

### Key Features

**1. Environment-Based Configuration**
```php
// database.php - Uses env vars
$host = getenv('DB_HOST') ?: 'localhost';
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASS') ?: 'admin123';
```
✅ **Pros**: Flexible for dev/prod
⚠️ **Issue**: Default values work locally but fail in production if ENV not set

**2. CORS Configuration (index.php)**
```php
$allowed_origins = [
    'http://localhost:5173',
    'http://localhost:3000',
    'http://localhost:8000',
    'http://localhost:8080',
    getenv('APP_URL') ?: 'https://seratif2026-production.up.railway.app',
];
```
✅ **Pros**: Prevents cross-origin attacks
⚠️ **Issue**: Hardcoded production URL

**3. Request Routing**
```php
$routes = [
    'POST' => [
        '/auth/register'    => __DIR__ . '/auth/register.php',
        '/auth/login'       => __DIR__ . '/auth/login.php',
        '/auth/logout'      => __DIR__ . '/auth/logout.php',
        '/upload-payment'   => __DIR__ . '/api/upload_payment.php',
        '/admin/login'      => __DIR__ . '/admin/login.php',
        '/admin/approve'    => __DIR__ . '/admin/payments.php',
    ],
    'GET' => [
        '/user/status'      => __DIR__ . '/api/user_status.php',
        '/admin/payments'   => __DIR__ . '/admin/payments.php',
    ],
];
```
✅ **Pros**: Simple and explicit routing
⚠️ **Issue**: No regex patterns for dynamic routes (handled separately)

**4. API Endpoints Summary**
| Method | Endpoint | File | Purpose |
|--------|----------|------|---------|
| POST | /auth/register | auth/register.php | User registration |
| POST | /auth/login | auth/login.php | User login |
| POST | /auth/logout | auth/logout.php | User logout |
| POST | /upload-payment | api/upload_payment.php | Upload payment proof |
| POST | /admin/login | admin/login.php | Admin login |
| POST | /admin/approve | admin/payments.php | Approve payment |
| GET | /user/status | api/user_status.php | Check session |
| GET | /admin/payments | admin/payments.php | List payments |
| GET | /ticket/{uuid} | api/ticket.php | Get ticket |
| GET | /validate/{uuid} | api/validate.php | Validate ticket |

---

## 🎨 FRONTEND ANALYSIS

### Structure
```
frontend/
├── src/
│   ├── main.jsx              ← Entry point
│   ├── App.jsx               ← Router & Routes
│   ├── index.css             ← TailwindCSS
│   ├── context/
│   │   └── AuthContext.jsx   ← Global auth state
│   ├── components/
│   │   └── Navbar.jsx        ← Navigation
│   └── pages/
│       ├── Landing.jsx       ← Home
│       ├── Login.jsx         ← User login
│       ├── Register.jsx      ← Registration
│       ├── Dashboard.jsx     ← User dashboard
│       ├── Validate.jsx      ← Validate ticket
│       └── admin/
│           ├── AdminLogin.jsx
│           ├── AdminPanel.jsx
│           ├── AdminScan.jsx
│           └── ParticipantDetail.jsx
├── index.html
├── package.json
├── vite.config.js
└── dist/                      ← Built & included in repo
```

### Key Features

**1. Route Protection**
```jsx
function ProtectedUser({ children }) {
  const { user, loading } = useAuth()
  if (loading) return <Spinner />
  return user ? children : <Navigate to="/login" replace />
}

function ProtectedAdmin({ children }) {
  const { admin, loading } = useAuth()
  return admin ? children : <Navigate to="/admin/login" replace />
}
```
✅ **Pros**: Prevents unauthorized access
✅ **Good**: Shows loading state

**2. API Calls (using relative paths)**
```jsx
// Login.jsx
const res = await fetch('/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',  // ← Important for sessions
    body: JSON.stringify(form),
})
```
✅ **Pros**: Relative paths work in both dev/prod
✅ **Good**: credentials: 'include' for cookies

**3. State Management (AuthContext.jsx)**
```jsx
const [user, setUser] = useState(null)      // User logged in?
const [admin, setAdmin] = useState(null)    // Admin logged in?
const [loading, setLoading] = useState(true)
const [token, setToken] = useState(null)    // Session token
```
✅ **Pros**: Centralized auth state

**4. Pages Overview**

| Page | Route | Purpose | Auth Required |
|------|-------|---------|---------------|
| Landing | / | Home, intro | No |
| Register | /register | User signup | No |
| Login | /login | User signin | No |
| Dashboard | /dashboard | User panel | User |
| Validate | /validate/:uuid | Check ticket | No |
| AdminLogin | /admin/login | Admin signin | No |
| AdminPanel | /admin | Payment review | Admin |
| AdminScan | /admin/scan | QR scanner | Admin |
| ParticipantDetail | /admin/participant/:uuid | User details | Admin |

---

## 🐳 DOCKER ANALYSIS (Dockerfile)

### Current Setup
```dockerfile
# Stage 1: Build Frontend
FROM node:20-alpine AS frontend-builder
COPY frontend/package*.json ./
RUN npm ci
RUN npm run build  ← Generates dist/

# Stage 2: PHP Runtime
FROM php:8.2-cli-alpine
COPY --from=frontend-builder /app/frontend/dist /app/dist
COPY backend/ /app/backend/
COPY backend/router.php /app/

EXPOSE 80
CMD ["php", "-S", "0.0.0.0:80", "-t", "/app", "router.php"]
```

### Issues Identified 🚨

**Issue 1: Router Path Conflict**
```php
// router.php tries to include backend/index.php
require __DIR__ . '/backend/index.php';  // ✅ Correct
```
But the working directory setup might be confused:
```
/app/
├── dist/              ← Frontend
├── backend/           ← Backend code
└── router.php         ← Main entry (at /app level)
```

When `chdir(__DIR__ . '/backend')` is called, paths might become relative to `/app/backend/` instead of `/app/`.

**Issue 2: require vs include - Error Handling**
```php
// In router.php - if backend/index.php crashes, server dies
require __DIR__ . '/backend/index.php';

// Should have error handling:
if (!file_exists($file)) {
    http_response_code(500);
    exit('Backend not found');
}
```

**Issue 3: No Graceful Fallback**
If frontend dist doesn't exist:
```php
if (file_exists(__DIR__ . '/dist/index.html')) {
    require __DIR__ . '/dist/index.html';  // ✅ OK
} else {
    echo 'Frontend not found';  // ✅ Good fallback
}
```

---

## 🚀 DEPLOYMENT ANALYSIS (Railway)

### Current Status
✅ Application deployed
✅ Code on GitHub
⚠️ **502 Error on requests** ← **ROOT CAUSE**

### Why 502 Error?

**The problem flow:**
```
1. Browser requests: GET /health
2. Railway receives request
3. PHP server at 0.0.0.0:80 receives it
4. router.php processes it
5. Tries to call backend/index.php
6. Backend/index.php tries to connect to database
7. Database not available
8. PHP throws exception
9. Server crashes/no response
10. Railway returns 502
```

### Database Issue
```bash
# Railway env vars set:
DB_HOST = mysql.railway.internal
DB_USER = root
DB_PASS = xRMeLntWWiuYkJoihNuhHSkrxQKXrbpJ

# BUT:
# 1. MySQL service may not be linked in Railway
# 2. Database "seratif2026" doesn't exist yet
# 3. Schema not imported
# 4. When backend tries Database::connect() → PDO fails
# 5. No error handling → Exception → Crash
```

---

## 🔗 ROUTING FLOW ANALYSIS

### Development Flow
```
Browser (localhost:5173)
  ↓
Vite dev server (proxies API calls)
  ├─ /auth/* → http://localhost:8000
  ├─ /admin/* → http://localhost:8000
  └─ /upload-payment → http://localhost:8000
  ↓
Backend at localhost:8000 (index.php)
  ├─ Routes static /uploads/
  ├─ Routes to auth/, admin/, api/
  └─ Serves content
  ↓
Database (localhost:3306)
```

### Production Flow (Current Issue)
```
Browser (seratif2026-production.up.railway.app)
  ↓
Railway Edge (HTTPS termination)
  ↓
PHP Server at 0.0.0.0:80 (in container)
  ├─ router.php at root
  │  ├─ /health → Works (simple JSON)
  │  ├─ /auth/login → Calls backend/index.php → DB required
  │  ├─ /dist/* → Static files → Works
  │  └─ / → SPA → Works
  ↓
backend/index.php (when called via router.php)
  ├─ Checks CORS
  ├─ Routes request
  ├─ Database::connect() ← CRASHES HERE
  │  └─ getenv('DB_HOST') = mysql.railway.internal
  │  └─ getenv('DB_USER') = root
  │  └─ getenv('DB_PASS') = ...
  │  └─ PDO connection fails
  └─ Exception thrown → No response → 502
```

---

## 📋 IDENTIFIED ISSUES

### Critical Issues (Blocking)

1. **Database Connection Fails**
   - Status: 🔴 BLOCKING
   - Cause: MySQL not connected / database doesn't exist
   - Effect: Any API call fails
   - Fix: Import schema to Railway MySQL

2. **Error Handling Missing**
   - Status: 🔴 BLOCKING
   - Cause: No try-catch in backend/index.php
   - Effect: Errors crash server → 502
   - Fix: Add error handlers

3. **Path Issues in Docker**
   - Status: 🟡 POTENTIAL
   - Cause: Working directory changes when router calls backend
   - Effect: Relative paths break
   - Fix: Use absolute paths

### Medium Issues

4. **No Health Check for Backend**
   - Status: 🟡 MEDIUM
   - Cause: /health endpoint only checks env vars, not DB
   - Effect: Can't verify backend is truly ready
   - Fix: Add DB connection test to /health

5. **Frontend Dist Not Included**
   - Status: 🟡 MEDIUM (Resolved)
   - Was: dist/ in .gitignore
   - Fixed: Updated .gitignore to include dist/

### Minor Issues

6. **Hardcoded Origins**
   - Status: 🟢 LOW
   - Cause: Localhost origins in CORS list
   - Effect: Unnecessary for production
   - Fix: Use environment-based CORS config

---

## 🎯 DATABASE SCHEMA

```sql
-- users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE,
    full_name VARCHAR(150),
    email VARCHAR(191) UNIQUE,
    password_hash VARCHAR(255),
    phone_number VARCHAR(20),
    address TEXT,
    school_origin VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- payments table
CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE,
    screenshot_path VARCHAR(500),
    status ENUM('pending','approved','rejected'),
    created_at TIMESTAMP,
    approved_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

---

## 📦 DEPENDENCIES

### Frontend (package.json)
```json
{
    "react": "^19.2.0",
    "react-dom": "^19.2.0",
    "react-router-dom": "^7.1.0",
    "html5-qrcode": "^2.3.8"
}
```
- React 19: Latest React
- React Router 7: Modern routing
- html5-qrcode: QR scanning for admin

### Backend (composer.json)
```
- bacon/bacon-qr-code: QR generation
- endroid/qr-code: Alternative QR library
- tecnickcom/tcpdf: PDF generation for tickets
```

### Docker
- FROM php:8.2-cli-alpine
- FROM node:20-alpine
- MySQL 8.0

---

## 🧪 LOCAL TESTING STATUS

✅ **Lokal (Development)**
- Backend: Works on localhost:8000
- Frontend: Works on localhost:5173
- Database: Connected (localhost:3306)
- Vite proxy: Routes API calls to backend

❌ **Production (Railway)**
- Frontend: Served (dist/)
- Backend: Can't connect to DB
- Database: Not set up
- Health check: Returns 502

---

## 📊 SUMMARY TABLE

| Component | Dev | Prod | Issue |
|-----------|-----|------|-------|
| Frontend Build | ✅ | ✅ | None |
| Frontend Static Serve | ✅ | ✅ | None |
| Backend Routing | ✅ | ❌ | Error handling |
| API Endpoints | ✅ | ❌ | DB connection |
| Database | ✅ | ⏳ | Not set up |
| CORS | ✅ | ✅ | None |
| Session Management | ✅ | ⏳ | DB dependent |
| File Uploads | ✅ | ⏳ | DB dependent |
| QR Scanning | ✅ | ⏳ | DB dependent |

---

## 🔧 NEXT STEPS (Priority Order)

1. **Import database schema to Railway MySQL**
2. **Add error handling to backend/index.php**
3. **Create /health endpoint that tests DB connection**
4. **Test each API endpoint individually**
5. **Monitor logs for new errors**

