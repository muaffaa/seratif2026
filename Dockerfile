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
# Start frontend server (main process)\n\
exec php -S 0.0.0.0:80 /app/router.php\n\
' > /app/start.sh && chmod +x /app/start.sh

# Create router for frontend
RUN cat > /app/router.php << 'PHPEOF'
<?php
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// API routes - include backend directly
if (preg_match('#^/(api|auth|ticket|validate|admin|upload-payment)#', $uri)) {
    $_SERVER['REQUEST_URI'] = $uri;
    $_SERVER['SCRIPT_FILENAME'] = '/app/backend/index.php';
    chdir('/app/backend');
    require '/app/backend/index.php';
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
