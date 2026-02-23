# Multi-stage build
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Backend stage
FROM php:8.2-apache
WORKDIR /app

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable mod_rewrite for pretty URLs
RUN a2enmod rewrite

# Copy frontend build output
COPY --from=frontend-builder /app/frontend/dist /var/www/html/dist

# Copy backend
COPY backend/ /var/www/html/

# Create Apache VirtualHost config
RUN cat > /etc/apache2/sites-available/000-default.conf << 'EOF'
<VirtualHost *:8080>
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        RewriteEngine On
        # Don't rewrite if file or directory exists
        RewriteCond %{REQUEST_FILENAME} -f [OR]
        RewriteCond %{REQUEST_FILENAME} -d
        RewriteRule ^ - [L]
        # Route all requests to api/index.php for API calls
        RewriteRule ^api/(.*)$ api/index.php [QSA,L]
        # Route SPA requests to dist/index.html
        RewriteRule ^(?!api/).*$ dist/index.html [QSA,L]
    </Directory>

    <Directory /var/www/html/dist>
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^ index.html [QSA,L]
    </Directory>
</VirtualHost>
EOF


# Expose port
EXPOSE 8080

# Set environment variables
ENV DB_HOST=${DB_HOST:-localhost}
ENV DB_NAME=${DB_NAME:-seratif2026}
ENV DB_USER=${DB_USER:-root}
ENV DB_PASS=${DB_PASS:-}
ENV PORT=8080

# Start Apache
CMD ["apache2-foreground"]
