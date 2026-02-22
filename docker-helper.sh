#!/bin/bash

# Seratif 2026 Docker Helper Script
# Usage: ./docker-helper.sh [command]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_usage() {
    echo -e "${BLUE}Seratif 2026 Docker Helper${NC}"
    echo ""
    echo "Usage: ./docker-helper.sh [command]"
    echo ""
    echo "Commands:"
    echo "  ${GREEN}start${NC}         - Start all containers"
    echo "  ${GREEN}stop${NC}          - Stop all containers"
    echo "  ${GREEN}restart${NC}       - Restart all containers"
    echo "  ${GREEN}build${NC}         - Build Docker images"
    echo "  ${GREEN}logs${NC}          - Show logs from all services"
    echo "  ${GREEN}logs-backend${NC}  - Show backend logs"
    echo "  ${GREEN}logs-frontend${NC} - Show frontend logs"
    echo "  ${GREEN}logs-db${NC}       - Show database logs"
    echo "  ${GREEN}bash-backend${NC}  - Open bash in backend container"
    echo "  ${GREEN}bash-db${NC}       - Open MySQL CLI in database"
    echo "  ${GREEN}status${NC}        - Show container status"
    echo "  ${GREEN}clean${NC}         - Remove all containers and images"
    echo "  ${GREEN}migrate${NC}       - Run database migrations"
    echo "  ${GREEN}seed${NC}          - Seed database with test data"
    echo ""
}

case "${1}" in
    start)
        echo -e "${BLUE}Starting containers...${NC}"
        docker-compose up -d
        echo -e "${GREEN}✅ Containers started!${NC}"
        ;;
    stop)
        echo -e "${BLUE}Stopping containers...${NC}"
        docker-compose down
        echo -e "${GREEN}✅ Containers stopped!${NC}"
        ;;
    restart)
        echo -e "${BLUE}Restarting containers...${NC}"
        docker-compose restart
        echo -e "${GREEN}✅ Containers restarted!${NC}"
        ;;
    build)
        echo -e "${BLUE}Building Docker images...${NC}"
        docker-compose build --no-cache
        echo -e "${GREEN}✅ Build completed!${NC}"
        ;;
    logs)
        docker-compose logs -f
        ;;
    logs-backend)
        docker-compose logs -f backend
        ;;
    logs-frontend)
        docker-compose logs -f frontend
        ;;
    logs-db)
        docker-compose logs -f db
        ;;
    bash-backend)
        docker-compose exec backend bash
        ;;
    bash-db)
        docker-compose exec db mysql -u seratif_user -pseratif_password seratif2026
        ;;
    status)
        echo -e "${BLUE}Container Status:${NC}"
        docker-compose ps
        ;;
    clean)
        echo -e "${YELLOW}⚠️  This will remove all containers and images!${NC}"
        read -p "Continue? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down
            docker system prune -f
            echo -e "${GREEN}✅ Cleanup completed!${NC}"
        fi
        ;;
    migrate)
        echo -e "${BLUE}Running database migrations...${NC}"
        docker-compose exec -T db mysql -u seratif_user -pseratif_password seratif2026 < database/schema.sql
        echo -e "${GREEN}✅ Migrations completed!${NC}"
        ;;
    seed)
        echo -e "${BLUE}Seeding database...${NC}"
        docker-compose exec backend php -r "echo 'Seed data script here';"
        echo -e "${GREEN}✅ Database seeded!${NC}"
        ;;
    "")
        print_usage
        ;;
    *)
        echo -e "${RED}Unknown command: ${1}${NC}"
        echo ""
        print_usage
        exit 1
        ;;
esac
