# Multi-stage build
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Backend stage
FROM php:8.2-cli-alpine
WORKDIR /app

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Copy frontend build output  
COPY --from=frontend-builder /app/frontend/dist /app/dist

# Copy backend
COPY backend/ /app/backend/

# Create .htaccess-like routing via PHP router
COPY backend/router.php /app/

# Expose port
EXPOSE 80

# Set environment and start
CMD ["php", "-S", "0.0.0.0:80", "-t", "/app", "router.php"]
