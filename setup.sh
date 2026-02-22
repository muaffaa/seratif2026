#!/bin/bash

# Seratif 2026 - Quick Setup & Deploy Script
# This script automates the Docker setup process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker tidak terinstall!"
        echo "Download dari: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    print_success "Docker ditemukan: $(docker --version)"
}

check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose tidak terinstall!"
        exit 1
    fi
    print_success "Docker Compose ditemukan: $(docker-compose --version)"
}

setup_env() {
    print_header "Setup Environment Variables"
    
    if [ -f .env ]; then
        print_warning ".env sudah ada, skip..."
    else
        cp .env.docker .env
        print_success ".env file dibuat dari .env.docker"
    fi
    
    echo "Edit .env untuk customize konfigurasi (opsional):"
    echo "  nano .env"
}

build_images() {
    print_header "Building Docker Images"
    docker-compose build --no-cache
    print_success "Build completed"
}

start_services() {
    print_header "Starting Services"
    docker-compose up -d
    print_success "Services started"
}

wait_for_db() {
    print_header "Waiting for Database"
    
    local count=0
    local max_attempts=30
    
    while [ $count -lt $max_attempts ]; do
        if docker-compose exec -T db mysqladmin ping -u root -padmin123 &> /dev/null; then
            print_success "Database is ready!"
            return 0
        fi
        
        count=$((count + 1))
        echo -ne "\rAttempt $count/$max_attempts..."
        sleep 1
    done
    
    print_error "Database gagal untuk ready dalam waktu yang ditentukan"
    return 1
}

show_status() {
    print_header "Service Status"
    docker-compose ps
}

show_access_info() {
    print_header "Access Information"
    
    echo -e "${GREEN}Services berhasil dijalankan!${NC}\n"
    
    echo -e "${BLUE}Frontend:${NC}"
    echo "  URL: http://localhost"
    echo "  Status: $(curl -s -o /dev/null -w '%{http_code}' http://localhost 2>/dev/null || echo 'Loading...')"
    echo ""
    
    echo -e "${BLUE}Backend API:${NC}"
    echo "  URL: http://localhost:8000"
    echo ""
    
    echo -e "${BLUE}phpMyAdmin (Database Management):${NC}"
    echo "  URL: http://localhost:8080"
    echo "  Username: seratif_user"
    echo "  Password: seratif_password"
    echo ""
    
    echo -e "${BLUE}Database Credentials:${NC}"
    echo "  Host: db (dalam docker) atau localhost:3306"
    echo "  Database: seratif2026"
    echo "  User: seratif_user"
    echo "  Password: seratif_password"
    echo ""
}

show_next_steps() {
    print_header "Next Steps"
    
    echo "1. Akses aplikasi di http://localhost"
    echo ""
    echo "2. Untuk development, lihat perintah yang tersedia:"
    echo "   ./docker-helper.sh"
    echo ""
    echo "3. View logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "4. Database operations:"
    echo "   docker-compose exec db mysql -u seratif_user -pseratif_password seratif2026"
    echo ""
    echo "5. Backend shell:"
    echo "   docker-compose exec backend bash"
    echo ""
}

# Main execution
main() {
    print_header "Seratif 2026 - Docker Setup"
    
    echo "Script ini akan:"
    echo "  1. Verify Docker installation"
    echo "  2. Setup environment variables"
    echo "  3. Build Docker images"
    echo "  4. Start all services"
    echo "  5. Wait for database ready"
    echo "  6. Show access information"
    echo ""
    
    read -p "Lanjutkan? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Setup dibatalkan"
        exit 0
    fi
    
    check_docker
    echo ""
    check_docker_compose
    echo ""
    
    setup_env
    echo ""
    
    build_images
    echo ""
    
    start_services
    echo ""
    
    wait_for_db
    echo ""
    
    show_status
    echo ""
    
    show_access_info
    
    show_next_steps
    
    print_header "Setup Selesai! 🎉"
}

# Run main
main
