#!/bin/bash
# Railway Post-deployment Script
# Runs after Railway deploys your application

set -e

echo "🎉 Post-deployment setup for Railway..."

# 1. Set permissions
echo "🔐 Setting permissions..."
chmod -R 755 backend/uploads
chmod -R 777 backend/uploads/payments

# 2. Warm up cache (if applicable)
echo "♨️ Warming up cache..."
# Add cache warming commands here if needed

# 3. Database verification
echo "🗄️ Verifying database..."
php -r "
require 'backend/config/database.php';
try {
    \$db = Database::connect();
    \$result = \$db->query('SELECT COUNT(*) FROM users');
    echo '✅ Database verified successfully';
} catch (Exception \$e) {
    echo '❌ Database error: ' . \$e->getMessage();
    exit(1);
}
"

# 4. Health check
echo "💓 Running health check..."
curl -f http://localhost:8000 || echo "Warning: Health check failed"

echo "✅ Post-deployment setup completed!"
