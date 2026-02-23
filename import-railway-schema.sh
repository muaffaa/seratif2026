#!/bin/bash

# Import database schema to Railway MySQL
# Usage: ./import-railway-schema.sh

echo "=========================================="
echo "Railway MySQL Schema Import"
echo "=========================================="
echo ""

# Get credentials from Railway environment
DB_HOST="${DB_HOST:-mysql.railway.internal}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS}"
DB_NAME="${DB_NAME:-seratif2026}"

if [ -z "$DB_PASS" ]; then
    read -sp "Enter MySQL password: " DB_PASS
    echo ""
fi

echo "Importing schema..."
echo "Host: $DB_HOST"
echo "User: $DB_USER"
echo "Database: $DB_NAME"
echo ""

# Create database and import schema
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" << EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE \`$DB_NAME\`;

-- Import schema from file
EOF

# Cat the schema file
cat database/schema.sql | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Schema imported successfully!"
else
    echo "❌ Import failed. Please check the error above."
    exit 1
fi

# Verify tables
echo ""
echo "Verifying tables..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES;" 2>&1 | tail -10

echo ""
echo "✅ Database setup complete!"
