#!/bin/bash
set -e

echo "🐳 Stopping Seratif 2026 containers..."
docker-compose down

echo "✅ Cleanup completed!"
echo ""
echo "To also remove volumes (database data):"
echo "  docker-compose down -v"
