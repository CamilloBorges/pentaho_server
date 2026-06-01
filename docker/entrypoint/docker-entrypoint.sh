#!/bin/bash
# =============================================================================
# Pentaho Server Docker Entrypoint Script
# =============================================================================
# This script:
# 1. Processes softwareOverride directory for configuration customization
# 2. Configures database connections for PostgreSQL
# 3. Sets JVM memory parameters
# 4. Starts Pentaho Server
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Environment variables with defaults
PENTAHO_HOME=${PENTAHO_HOME:-/opt/pentaho/pentaho-server}
POSTGRES_HOST=${POSTGRES_HOST:-repository}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-password}
PENTAHO_USER=${PENTAHO_USER:-pentaho}
PENTAHO_PASSWORD=${PENTAHO_PASSWORD:-password}
PENTAHO_MIN_MEMORY=${PENTAHO_MIN_MEMORY:-2048m}
PENTAHO_MAX_MEMORY=${PENTAHO_MAX_MEMORY:-4096m}

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

# =============================================================================
# Process Software Override Directory
# =============================================================================
process_software_override() {
    local override_base="/opt/pentaho/softwareOverride"
    
    if [ ! -d "$override_base" ]; then
        log_warn "Software override directory not found: $override_base"
        return 0
    fi
    
    log "Processing software override directories..."
    
    # Process directories in alphabetical order
    for override_dir in $(find "$override_base" -mindepth 1 -maxdepth 1 -type d | sort); do
        local dir_name=$(basename "$override_dir")
        
        # Skip if .ignore file exists
        if [ -f "$override_dir/.ignore" ]; then
            log_warn "Skipping $dir_name (ignored)"
            continue
        fi
        
        log "Processing: $dir_name"
        
        # Copy files maintaining directory structure
        if [ -d "$override_dir" ]; then
            cp -rfv "$override_dir"/* "$PENTAHO_HOME/" 2>/dev/null || true
        fi
    done
    
    log "Software override processing completed"
}

# =============================================================================
# Wait for PostgreSQL
# =============================================================================
wait_for_postgres() {
    log "Waiting for PostgreSQL at $POSTGRES_HOST:$POSTGRES_PORT..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z "$POSTGRES_HOST" "$POSTGRES_PORT" 2>/dev/null; then
            log "PostgreSQL is ready!"
            return 0
        fi
        
        log "Attempt $attempt/$max_attempts - PostgreSQL not ready yet..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log_error "PostgreSQL failed to become ready after $max_attempts attempts"
    exit 1
}

# =============================================================================
# Configure Database Connections
# =============================================================================
configure_database() {
    log "Configuring database connections..."
    
    local repo_config="$PENTAHO_HOME/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties"
    local hibernate_config="$PENTAHO_HOME/pentaho-solutions/system/hibernate/hibernate-settings.xml"
    local quartz_config="$PENTAHO_HOME/pentaho-solutions/system/quartz/quartz.properties"
    local context_xml="$PENTAHO_HOME/tomcat/webapps/pentaho/META-INF/context.xml"
    
    # Update repository config
    if [ -f "$repo_config" ]; then
        sed -i "s|jdbc.driver=.*|jdbc.driver=org.postgresql.Driver|g" "$repo_config"
        sed -i "s|jdbc.url=.*|jdbc.url=jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/hibernate|g" "$repo_config"
        sed -i "s|jdbc.username=.*|jdbc.username=hibuser|g" "$repo_config"
        sed -i "s|jdbc.password=.*|jdbc.password=$PENTAHO_PASSWORD|g" "$repo_config"
    fi
    
    # Update Quartz config
    if [ -f "$quartz_config" ]; then
        sed -i "s|org.quartz.jobStore.driverDelegateClass.*|org.quartz.jobStore.driverDelegateClass = org.quartz.impl.jdbcjobstore.PostgreSQLDelegate|g" "$quartz_config"
        sed -i "s|org.quartz.dataSource.myDS.driver.*|org.quartz.dataSource.myDS.driver = org.postgresql.Driver|g" "$quartz_config"
        sed -i "s|org.quartz.dataSource.myDS.URL.*|org.quartz.dataSource.myDS.URL = jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/quartz|g" "$quartz_config"
        sed -i "s|org.quartz.dataSource.myDS.user.*|org.quartz.dataSource.myDS.user = pentaho_user|g" "$quartz_config"
        sed -i "s|org.quartz.dataSource.myDS.password.*|org.quartz.dataSource.myDS.password = $PENTAHO_PASSWORD|g" "$quartz_config"
    fi
    
    log "Database configuration completed"
}

# =============================================================================
# Configure Tomcat Context XML (PostgreSQL Datasources)
# =============================================================================
configure_context_xml() {
    log "Configuring Tomcat context.xml for PostgreSQL datasources..."
    
    local meta_inf_dir="$PENTAHO_HOME/tomcat/webapps/pentaho/META-INF"
    local context_xml="$meta_inf_dir/context.xml"
    local override_file="/opt/pentaho/context.xml.override"
    
    # Create META-INF directory if it doesn't exist
    if [ ! -d "$meta_inf_dir" ]; then
        log "Creating META-INF directory: $meta_inf_dir"
        mkdir -p "$meta_inf_dir"
    fi
    
    # Copy PostgreSQL context.xml if override file exists
    if [ -f "$override_file" ]; then
        log "Copying PostgreSQL context.xml to: $context_xml"
        cp "$override_file" "$context_xml"
        log "✓ Context.xml configured for PostgreSQL datasources"
    else
        log_warn "Override file not found: $override_file"
    fi
}

# =============================================================================
# Configure JVM Memory
# =============================================================================
configure_memory() {
    log "Configuring JVM memory: Min=$PENTAHO_MIN_MEMORY, Max=$PENTAHO_MAX_MEMORY"
    
    local setenv_sh="$PENTAHO_HOME/tomcat/bin/setenv.sh"
    
    if [ -f "$setenv_sh" ]; then
        # Update memory settings
        sed -i "s/-Xms[0-9]*[mMgG]/-Xms$PENTAHO_MIN_MEMORY/g" "$setenv_sh"
        sed -i "s/-Xmx[0-9]*[mMgG]/-Xmx$PENTAHO_MAX_MEMORY/g" "$setenv_sh"
    fi
    
    log "Memory configuration completed"
}

# =============================================================================
# Start Pentaho Server
# =============================================================================
start_pentaho() {
    log "Starting Pentaho Server..."
    
    cd "$PENTAHO_HOME"
    
    # Start Tomcat
    exec "$PENTAHO_HOME/tomcat/bin/catalina.sh" run
}

# =============================================================================
# Main Execution
# =============================================================================
main() {
    log "========================================="
    log "Pentaho Server CE Docker Container"
    log "Version: $PENTAHO_VERSION"
    log "========================================="
    
    # Process software overrides (if mounted)
    if [ -d "/opt/pentaho/softwareOverride" ]; then
        process_software_override
    fi
    
    # Wait for PostgreSQL
    wait_for_postgres
    
    # Configure Tomcat context.xml (MUST be before Tomcat starts)
    configure_context_xml
    
    # Configure database
    configure_database
    
    # Configure memory
    configure_memory
    
    # Start Pentaho
    start_pentaho
}

# Execute main function
main "$@"
