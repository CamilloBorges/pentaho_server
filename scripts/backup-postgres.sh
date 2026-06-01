#!/bin/bash
# =============================================================================
# Pentaho PostgreSQL Database Backup Script
# =============================================================================
# Creates compressed backups of all Pentaho databases
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

# Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/pentaho-postgres-backup-$TIMESTAMP.sql.gz"

# Create backup directory
mkdir -p "$BACKUP_DIR"

log "Starting PostgreSQL backup..."
log "Backup file: $BACKUP_FILE"

# Check if postgres container is running
if ! docker compose ps postgres | grep -q "running"; then
    log_error "PostgreSQL container is not running"
    exit 1
fi

# Perform backup
log "Backing up all Pentaho databases..."

docker compose exec -T postgres pg_dumpall -U postgres | gzip > "$BACKUP_FILE"

# Check if backup was successful
if [ -f "$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log "Backup completed successfully!"
    log "File: $BACKUP_FILE"
    log "Size: $BACKUP_SIZE"
else
    log_error "Backup failed!"
    exit 1
fi

# List recent backups
log "Recent backups:"
ls -lh "$BACKUP_DIR" | tail -5

log "Backup process completed"
