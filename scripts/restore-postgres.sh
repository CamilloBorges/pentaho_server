#!/bin/bash
# =============================================================================
# Pentaho PostgreSQL Database Restore Script
# =============================================================================
# Restores PostgreSQL databases from a backup file
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check arguments
if [ $# -eq 0 ]; then
    log_error "Usage: $0 <backup-file.sql.gz>"
    log "Available backups:"
    ls -lh ./backups/*.sql.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"

# Verify backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    log_error "Backup file not found: $BACKUP_FILE"
    exit 1
fi

log "Restoring from backup: $BACKUP_FILE"

# Check if postgres container is running
if ! docker compose ps postgres | grep -q "running"; then
    log_error "PostgreSQL container is not running"
    log "Start with: docker compose up -d postgres"
    exit 1
fi

# Warning
log_warn "This will OVERWRITE all current databases!"
read -p "Are you sure you want to continue? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    log "Restore cancelled"
    exit 0
fi

# Stop Pentaho Server
log "Stopping Pentaho Server..."
docker compose stop pentaho-server

# Restore database
log "Restoring databases..."
gunzip -c "$BACKUP_FILE" | docker compose exec -T postgres psql -U postgres

log "Restore completed successfully!"
log "Starting services..."
docker compose up -d

log "Restore process completed"
log "Monitor startup with: docker compose logs -f pentaho-server"
