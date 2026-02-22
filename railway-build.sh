#!/bin/bash
# Railway Pre-deployment Script
# Runs before Railway deploys your application

set -e

echo "🚀 Pre-deployment checks for Railway..."

# 1. Run database migrations
echo "📦 Initializing database..."
php -r "require 'backend/config/database.php'; Database::connect(); echo 'Database connection successful';"

# 2. Check PHP version
echo "🐘 PHP version check..."
php -v

# 3. Check required extensions
echo "📋 Checking PHP extensions..."
php -m | grep -E 'pdo|mysql|gd|zip' || echo "Warning: Some extensions might be missing"

# 4. Create necessary directories
echo "📁 Creating directories..."
mkdir -p backend/uploads/payments
chmod -R 777 backend/uploads

# 5. Clear any cache
echo "🧹 Clearing cache..."
rm -rf backend/uploads/cache/* 2>/dev/null || true

echo "✅ Pre-deployment checks completed!"
