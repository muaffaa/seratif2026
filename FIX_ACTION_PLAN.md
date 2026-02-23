# 🛠️ SERATIF2026 - FIX ACTION PLAN

## 🎯 Main Problem

**502 Error in Production** is caused by:
1. ❌ Backend crashes when trying to connect to non-existent database
2. ❌ No error handling to catch crashes
3. ❌ No graceful fallback when database unavailable

---

## 📋 ACTION PLAN

### Phase 1: Add Error Handling (Immediate - 15 min)

**File: `backend/index.php`**

Add try-catch wrapper around database operations:

```php
<?php
// ... existing code ...

try {
    // Routes and database calls here
    if (isset($routes[$method][$uri])) {
        // Load the route file
        ob_start();
        require $routes[$method][$uri];
        ob_end_flush();
        exit;
    }
} catch (PDOException $e) {
    http_response_code(503);
    header('Content-Type: application/json');
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed',
        'error' => 'Service temporarily unavailable'
    ]);
    exit;
} catch (Exception $e) {
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode([
        'success' => false,
        'message' => 'Server error',
        'error' => $e->getMessage()
    ]);
    exit;
}

// 404
header('Content-Type: application/json');
http_response_code(404);
echo json_encode(['success' => false, 'message' => 'Endpoint not found.']);
?>
```

**File: `backend/config/database.php`**

Add better error handling:

```php
<?php
class Database {
    private static ?PDO $instance = null;

    public static function connect(): PDO {
        if (self::$instance !== null) {
            return self::$instance;
        }

        $host    = getenv('DB_HOST')    ?: 'localhost';
        $dbname  = getenv('DB_NAME')    ?: 'seratif2026';
        $user    = getenv('DB_USER')    ?: 'root';
        $pass    = getenv('DB_PASS')    ?: '';
        $charset = 'utf8mb4';

        try {
            $dsn = "mysql:host=$host;dbname=$dbname;charset=$charset";
            $pdo = new PDO($dsn, $user, $pass, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
                PDO::ATTR_TIMEOUT => 5,
            ]);
            self::$instance = $pdo;
            return $pdo;
        } catch (PDOException $e) {
            // Log error
            error_log('Database connection failed: ' . $e->getMessage());
            throw new PDOException('Database connection failed. Please check your configuration.');
        }
    }
}
?>
```

✅ **Result**: API will return 503 instead of 502 when database unavailable

---

### Phase 2: Create Database Health Check (10 min)

**File: `backend/api/health.php`**

```php
<?php
declare(strict_types=1);

header('Content-Type: application/json');

$response = [
    'status' => 'ok',
    'timestamp' => date('Y-m-d H:i:s'),
    'environment' => getenv('RAILWAY_ENVIRONMENT') ?: 'local',
    'database' => [
        'host' => getenv('DB_HOST') ?: 'not-set',
        'status' => 'unknown'
    ]
];

try {
    // Try to connect to database
    require __DIR__ . '/../config/database.php';
    $db = Database::connect();
    
    // Test query
    $result = $db->query('SELECT 1');
    
    $response['database']['status'] = 'connected';
    $response['app_version'] = '1.0.0';
} catch (Exception $e) {
    $response['status'] = 'degraded';
    $response['database']['status'] = 'error';
    $response['database']['error'] = $e->getMessage();
    http_response_code(503);
}

echo json_encode($response);
?>
```

**Update: `backend/index.php`**

Add route:
```php
// Health check
if ($method === 'GET' && $uri === '/health') {
    require __DIR__ . '/api/health.php';
    exit;
}
```

✅ **Result**: Can test if database is really connected via `/health`

---

### Phase 3: Import Database Schema (5 min)

After MySQL is provisioned in Railway:

**Option A: Via Railway Console**
```bash
# Open Railway MySQL admin
# Run database/schema.sql
```

**Option B: Via CLI (if you have access)**
```bash
./import-railway-schema.sh
```

**Option C: Manual SQL**
```bash
mysql -h mysql.railway.internal \
      -u root \
      -p"xRMeLntWWiuYkJoihNuhHSkrxQKXrbpJ" \
      seratif2026 < database/schema.sql
```

✅ **Result**: Tables created and ready for data

---

### Phase 4: Deploy Fixed Code (2 min)

```bash
cd /home/muaffaa/Documents/myRepo/seratif2026

# Add and commit changes
git add backend/
git commit -m "Add error handling and health check endpoint"

# Push to GitHub
git push origin main

# Deploy to Railway
railway up --detach
```

✅ **Result**: New code deployed with error handling

---

### Phase 5: Verify Deployment (5 min)

```bash
# Wait 30 seconds for deployment
sleep 30

# Test health endpoint
curl https://seratif2026-production.up.railway.app/health

# Expected response:
# {
#   "status": "ok",
#   "database": {
#     "status": "connected"
#   }
# }

# Test frontend
curl https://seratif2026-production.up.railway.app/
# Should return HTML with "SERATIF 2026"
```

✅ **Result**: Application working end-to-end

---

## 📝 CODE CHANGES SUMMARY

### File 1: `backend/index.php`
**Change**: Add try-catch and health check route
**Lines**: Add ~50 lines
**Impact**: Prevents 502 errors, handles exceptions gracefully

### File 2: `backend/config/database.php`
**Change**: Add error handling in PDO connection
**Lines**: Modify ~20 lines
**Impact**: Better error messages, clearer failure reason

### File 3: `backend/api/health.php` (NEW)
**Change**: Create new health check file
**Lines**: ~40 lines
**Impact**: Can verify backend + database status

---

## 🧪 Testing Checklist

After deployment, test in order:

```bash
# 1. Health check (no DB dependency)
[ ] curl https://seratif2026-production.up.railway.app/health → 200

# 2. Frontend SPA (static files)
[ ] Browser: https://seratif2026-production.up.railway.app → Landing page

# 3. API with DB (after schema imported)
[ ] POST /auth/register → Success
[ ] POST /auth/login → Success
[ ] GET /user/status → Returns user or null
[ ] GET /admin/payments → 401 or success (depending on login)

# 4. Static files
[ ] /dist/*.js, /dist/*.css load
[ ] Images in /public/images load

# 5. SPA routing
[ ] Manual navigation works (/register, /dashboard, etc)
[ ] Refresh page keeps state
```

---

## 🚨 Potential Issues & Solutions

### Issue: Still getting 502 error
**Cause**: Database not connected
**Solution**: Check Railway logs: `railway logs`
**Fix**: Run `./import-railway-schema.sh` with correct credentials

### Issue: /health returns 503
**Cause**: Database credentials wrong
**Solution**: 
```bash
railway variable list
# Verify DB_HOST, DB_USER, DB_PASS are correct
```

### Issue: Frontend loads but APIs fail
**Cause**: Database doesn't have tables
**Solution**: Import schema using `./import-railway-schema.sh`

### Issue: CORS errors in browser console
**Cause**: Origin not in allowed list
**Solution**: Update `$allowed_origins` in backend/index.php

---

## ⏰ Estimated Timeline

| Phase | Task | Time |
|-------|------|------|
| 1 | Add error handling | 15 min |
| 2 | Create health check | 10 min |
| 3 | Import schema | 5 min |
| 4 | Deploy | 2 min |
| 5 | Verify | 5 min |
| **Total** | | **37 min** |

---

## ✅ Success Criteria

Application is **DONE** when:

- ✅ Health endpoint returns 200
- ✅ Frontend SPA loads correctly  
- ✅ User registration works
- ✅ User login works
- ✅ Admin login works
- ✅ Payment upload works
- ✅ QR scan works
- ✅ Ticket download works
- ✅ No 502 or 503 errors
- ✅ No console errors in browser

---

## 📚 Reference Files

- Analysis: [CODE_ANALYSIS.md](CODE_ANALYSIS.md)
- Setup Guide: [RAILWAY_SETUP.md](RAILWAY_SETUP.md)
- Deployment Summary: [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md)
- Database Schema: [database/schema.sql](database/schema.sql)
- Import Script: [import-railway-schema.sh](import-railway-schema.sh)

