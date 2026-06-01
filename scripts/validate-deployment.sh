#!/bin/bash
# =============================================================================
# Pentaho Server CE - Deployment Validation Script
# =============================================================================
# Validates the deployment and checks service health
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}$1${NC}"; }

ERRORS=0

check() {
    if $1; then
        log "$2"
        return 0
    else
        log_error "$2"
        ((ERRORS++))
        return 1
    fi
}

# =============================================================================
# Container Checks
# =============================================================================
log_section "Checking Docker Containers"

check "docker compose ps postgres | grep -q 'running'" "PostgreSQL container is running"
check "docker compose ps pentaho-server | grep -q 'running'" "Pentaho Server container is running"

# =============================================================================
# PostgreSQL Checks
# =============================================================================
log_section "Checking PostgreSQL"

check "docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1" "PostgreSQL is accepting connections"

# Check databases
if docker compose exec -T postgres psql -U postgres -lqt | cut -d \| -f 1 | grep -qw jackrabbit; then
    log "Database 'jackrabbit' exists"
else
    log_error "Database 'jackrabbit' not found"
    ((ERRORS++))
fi

if docker compose exec -T postgres psql -U postgres -lqt | cut -d \| -f 1 | grep -qw quartz; then
    log "Database 'quartz' exists"
else
    log_error "Database 'quartz' not found"
    ((ERRORS++))
fi

if docker compose exec -T postgres psql -U postgres -lqt | cut -d \| -f 1 | grep -qw hibernate; then
    log "Database 'hibernate' exists"
else
    log_error "Database 'hibernate' not found"
    ((ERRORS++))
fi

# =============================================================================
# Pentaho Server Checks
# =============================================================================
log_section "Checking Pentaho Server"

# Check if Pentaho is responding
if curl -f -s -o /dev/null http://localhost:8080/pentaho/Login 2>/dev/null; then
    log "Pentaho Server is responding"
else
    log_warn "Pentaho Server is not responding yet (may still be starting up)"
fi

# =============================================================================
# Network Checks
# =============================================================================
log_section "Checking Network"

check "docker network inspect pentaho-net > /dev/null 2>&1" "Docker network 'pentaho-net' exists"

# =============================================================================
# Volume Checks
# =============================================================================
log_section "Checking Volumes"

check "docker volume inspect pentaho_postgres_data > /dev/null 2>&1" "Volume 'pentaho_postgres_data' exists"
check "docker volume inspect pentaho_solutions > /dev/null 2>&1" "Volume 'pentaho_solutions' exists"
check "docker volume inspect pentaho_data > /dev/null 2>&1" "Volume 'pentaho_data' exists"

# =============================================================================
# Summary
# =============================================================================
log_section "Validation Summary"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    echo ""
    log "Access Pentaho Server at: http://localhost:8080/pentaho"
    log "Default credentials: admin / password"
    exit 0
else
    echo -e "${RED}Validation failed with $ERRORS error(s)${NC}"
    echo ""
    log_warn "Check logs with: docker compose logs"
    exit 1
fi
