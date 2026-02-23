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
COPY --from=frontend-builder /app/frontend/dist /app/frontend/dist

# Copy backend
COPY backend/ /app/backend/

# Create startup script
RUN cat > /app/start.sh << 'BASHEOF'
#!/bin/bash
export DB_HOST=${DB_HOST:-localhost}
export DB_NAME=${DB_NAME:-seratif2026}
export DB_USER=${DB_USER:-root}
export DB_PASS=${DB_PASS:-}

# Start PHP built-in server for backend
cd /app/backend && php -S 0.0.0.0:8000 index.php &

# Wait a moment
sleep 1

# Create simple router for frontend in current shell
cd /app && php -r "
\$root = '/app/frontend/dist';
\$uri = parse_url(\$_SERVER['REQUEST_URI'], PHP_URL_PATH);
\$file = \$root . \$uri;

// If URI is /api or /auth, proxy to backend
if (strpos(\$uri, '/api') === 0 || strpos(\$uri, '/auth') === 0 || strpos(\$uri, '/ticket') === 0 || strpos(\$uri, '/validate') === 0 || strpos(\$uri, '/admin') === 0 || strpos(\$uri, '/upload-payment') === 0) {
    http_response_code(500);
    die('Proxy to backend on :8000');
}

// If it's a file, serve it
if (file_exists(\$file) && is_file(\$file)) {
    return false;
}

// If it's a directory with index.html
if (is_dir(\$file) && file_exists(\$file . '/index.html')) {
    return false;
}

// Otherwise serve index.html (SPA)
require \$root . '/index.html';
" -S 0.0.0.0:80 2>&1 &

wait
BASHEOF
RUN chmod +x /app/start.sh

# Expose port
EXPOSE 80 8000

# Start servers
CMD ["/app/start.sh"]
