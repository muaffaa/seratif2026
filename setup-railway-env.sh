#!/bin/bash

# Railway Environment Variables Setup Script
# This script helps configure environment variables in Railway for database connection

echo "=========================================="
echo "Seratif2026 - Railway Setup Helper"
echo "=========================================="
echo ""

# Check if railway CLI is available
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Install it first:"
    echo "   npm install -g @railway/cli"
    exit 1
fi

# Prompt for MySQL details
echo "Enter your Railway MySQL credentials:"
echo "(You can find these in Railway Dashboard → MySQL Service → Variables)"
echo ""

read -p "DB_HOST (e.g., mysql.railway.internal): " DB_HOST
read -p "DB_USER (e.g., root): " DB_USER
read -sp "DB_PASS: " DB_PASS
echo ""

# Default values
DB_NAME="seratif2026"
DB_PORT="3306"

# Show summary
echo ""
echo "=========================================="
echo "Configuration Summary:"
echo "=========================================="
echo "DB_HOST: $DB_HOST"
echo "DB_NAME: $DB_NAME"
echo "DB_USER: $DB_USER"
echo "DB_PORT: $DB_PORT"
echo "=========================================="
echo ""

# Confirm
read -p "Proceed with setting these variables? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

# Set variables using railway CLI
echo ""
echo "Setting Railway environment variables..."

railway variable set DB_HOST="$DB_HOST"
railway variable set DB_NAME="$DB_NAME"
railway variable set DB_USER="$DB_USER"
railway variable set DB_PASS="$DB_PASS"
railway variable set DB_PORT="$DB_PORT"

echo ""
echo "✅ Environment variables set successfully!"
echo ""
echo "Next steps:"
echo "1. Run database schema in your Railway MySQL:"
echo "   mysql -h $DB_HOST -u $DB_USER -p$DB_PASS < database/schema.sql"
echo "2. Redeploy: railway up"
echo "3. Test: curl https://seratif2026-production.up.railway.app/health"
echo ""
