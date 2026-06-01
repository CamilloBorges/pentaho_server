#!/bin/bash
# =============================================================================
# Pentaho Server CE - Automated Deployment Script
# =============================================================================
# This script automates the deployment of Pentaho Server CE with PostgreSQL
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_section() { echo -e "\n${BLUE}========================================${NC}\n${BLUE}$1${NC}\n${BLUE}========================================${NC}"; }

# =============================================================================
# Pre-flight Checks
# =============================================================================
preflight_checks() {
    log_section "Running Pre-flight Checks"
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    log "✓ Docker found: $(docker --version)"
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not installed or not available"
        exit 1
    fi
    log "✓ Docker Compose found: $(docker compose version)"
    
    # Check if pentaho zip exists
    if ! ls docker/stagedArtifacts/pentaho-server-ce-*.zip 1> /dev/null 2>&1; then
        log_error "Pentaho Server CE package not found in docker/stagedArtifacts/"
        log_error "Please download and place pentaho-server-ce-*.zip in docker/stagedArtifacts/"
        exit 1
    fi
    log "✓ Pentaho Server CE package found"
    
    # Check .env file
    if [ ! -f ".env" ]; then
        log_warn ".env file not found, creating from template..."
        cp .env.template .env
        log "✓ Created .env from template"
    else
        log "✓ .env file found"
    fi
    
    # Check secrets
    if [ ! -f "secrets/postgres_password.txt" ]; then
        log_warn "PostgreSQL password file not found, creating..."
        echo "password" > secrets/postgres_password.txt
        log "✓ Created default PostgreSQL password file"
    else
        log "✓ PostgreSQL password file found"
    fi
    
    log_section "Pre-flight Checks Completed"
}

# =============================================================================
# Build Images
# =============================================================================
build_images() {
    log_section "Building Docker Images"
    
    log "Building Pentaho Server image..."
    docker compose build --no-cache pentaho-server
    
    log_section "Image Build Completed"
}

# =============================================================================
# Start Services
# =============================================================================
start_services() {
    log_section "Starting Services"
    
    log "Starting PostgreSQL database..."
    docker compose up -d postgres
    
    log "Waiting for PostgreSQL to be ready..."
    sleep 10
    
    local max_attempts=30
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        if docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
            log "✓ PostgreSQL is ready"
            break
        fi
        log "Waiting for PostgreSQL... (attempt $attempt/$max_attempts)"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "PostgreSQL failed to start"
        exit 1
    fi
    
    log "Starting Pentaho Server..."
    docker compose up -d pentaho-server
    
    log_section "Services Started"
}

# =============================================================================
# Display Access Information
# =============================================================================
display_info() {
    log_section "Deployment Completed"
    
    echo ""
    log "Pentaho Server is starting up..."
    log "This may take 2-5 minutes depending on your system."
    echo ""
    log "Access URLs:"
    echo "  • Pentaho Server: http://localhost:8080/pentaho"
    echo "  • Default Credentials:"
    echo "    - Username: admin"
    echo "    - Password: password"
    echo ""
    log "PostgreSQL:"
    echo "  • Host: localhost"
    echo "  • Port: 5432"
    echo "  • Password: password"
    echo ""
    log "Useful Commands:"
    echo "  • View logs: docker compose logs -f pentaho-server"
    echo "  • Stop services: docker compose stop"
    echo "  • Restart services: docker compose restart"
    echo "  • Remove all: docker compose down -v"
    echo ""
    log "Monitor startup with: docker compose logs -f pentaho-server"
    log "Wait for 'Server startup in [X] milliseconds' message"
    echo ""
}

# =============================================================================
# Main Execution
# =============================================================================
main() {
    log_section "Pentaho Server CE - Docker Deployment"
    
    preflight_checks
    build_images
    start_services
    display_info
    
    log "Deployment script completed successfully!"
}

main "$@"
