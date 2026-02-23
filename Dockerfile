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

# Fix MPM issue - disable all conflicting MPM modules
RUN rm -f /etc/apache2/mods-enabled/mpm_*.load && \
    a2enmod mpm_prefork

# Enable mod_rewrite for pretty URLs
RUN a2enmod rewrite

# Copy frontend build output
COPY --from=frontend-builder /app/frontend/dist /var/www/html/dist

# Copy backend
COPY backend/ /var/www/html/

# Create Apache VirtualHost config
RUN cat > /etc/apache2/sites-available/000-default.conf << 'EOF'
<VirtualHost *:80>
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

RUN a2ensite 000-default

# Expose port
EXPOSE 80

# Set environment variables
ENV DB_HOST=${DB_HOST:-localhost}
ENV DB_NAME=${DB_NAME:-seratif2026}
ENV DB_USER=${DB_USER:-root}
ENV DB_PASS=${DB_PASS:-}

# Start Apache
CMD ["apache2-foreground"]
