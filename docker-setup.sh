#!/bin/bash
set -e

echo "🐳 Building Seratif 2026 Docker Images..."
docker-compose build

echo ""
echo "✅ Build completed!"
echo ""
echo "🚀 Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for database to be ready..."
sleep 10

echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "✨ Seratif 2026 is running!"
echo ""
echo "📍 Access points:"
echo "   Frontend:   http://localhost"
echo "   Backend:    http://localhost:8000"
echo "   phpMyAdmin: http://localhost:8080"
echo "   Credentials: seratif_user / seratif_password"
echo ""
