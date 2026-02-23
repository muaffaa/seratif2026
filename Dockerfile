# Multi-stage build
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Backend stage - use PHP CLI with built-in server
FROM php:8.2-cli
WORKDIR /app

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Copy frontend build output
COPY --from=frontend-builder /app/frontend/dist /app/public_html

# Copy backend
COPY backend/ /app/backend/

# Create simple startup script
RUN echo '#!/bin/bash\n\
export DB_HOST=${DB_HOST:-localhost}\n\
export DB_NAME=${DB_NAME:-seratif2026}\n\
export DB_USER=${DB_USER:-root}\n\
export DB_PASS=${DB_PASS:-}\n\
\n\
# Start backend server\n\
cd /app/backend && php -S 127.0.0.1:8000 index.php > /tmp/backend.log 2>&1 &\n\
BACKEND_PID=$!\n\
\n\
# Start frontend server with routing\n\
cd /app && php -S 0.0.0.0:80 router.php > /tmp/frontend.log 2>&1 &\n\
FRONTEND_PID=$!\n\
\n\
wait $BACKEND_PID $FRONTEND_PID\n\
' > /app/start.sh && chmod +x /app/start.sh

# Create router for frontend
RUN cat > /app/router.php << 'PHPEOF'
<?php
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// API routes - proxy to backend
if (preg_match('#^/(api|auth|ticket|validate|admin|upload-payment)#', $uri)) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://127.0.0.1:8000' . $_SERVER['REQUEST_URI']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $_SERVER['REQUEST_METHOD']);
    
    // Forward headers
    $headers = [];
    foreach (getallheaders() as $name => $value) {
        $headers[] = $name . ': ' . $value;
    }
    if (!empty($headers)) {
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    }
    
    // Forward body for POST/PUT
    if (in_array($_SERVER['REQUEST_METHOD'], ['POST', 'PUT'])) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, file_get_contents('php://input'));
    }
    
    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    http_response_code($http_code);
    echo $response;
    return true;
}

// Static files
$file = '/app/public_html' . $uri;
if (is_file($file)) {
    return false;
}

// Serve index.html for SPA routes
if (is_dir($file) || !file_exists($file)) {
    require '/app/public_html/index.html';
    return true;
}
PHPEOF

# Expose port
EXPOSE 80

# Start services
CMD ["/app/start.sh"]
