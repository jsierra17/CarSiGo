#!/bin/bash

# CarSiGo Staging PostgreSQL Setup Script
# Usage: ./setup-postgres.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DB_NAME="carsigo_staging"
DB_USER="staging_user"
DB_PASSWORD="staging_password_here"
POSTGRES_CONTAINER="carsigo_staging_postgres"
LOG_FILE="/var/log/carsigo-staging-postgres-setup.log"

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}" | tee -a "$LOG_FILE"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run as root"
    exit 1
fi

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

log "Starting CarSiGo Staging PostgreSQL Setup"

# Wait for PostgreSQL container to be ready
log "Waiting for PostgreSQL container to be ready..."
for i in {1..30}; do
    if docker exec "$POSTGRES_CONTAINER" pg_isready -U postgres > /dev/null 2>&1; then
        log "PostgreSQL is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        error "PostgreSQL container is not ready after 30 seconds"
        exit 1
    fi
    sleep 1
done

# Create database if not exists
log "Creating database: $DB_NAME"
docker exec "$POSTGRES_CONTAINER" psql -U postgres -c "
    CREATE DATABASE $DB_NAME ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C';
" 2>/dev/null || {
    log "Database already exists or creation failed, continuing..."
}

# Create user if not exists
log "Creating database user: $DB_USER"
docker exec "$POSTGRES_CONTAINER" psql -U postgres -c "
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$DB_USER') THEN
            CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
        END IF;
    END
    \$\$;
    
    GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
    ALTER USER $DB_USER CREATEDB;
" || {
    error "Failed to create database user"
    exit 1
}

# Grant permissions on schema
log "Setting up permissions..."
docker exec "$POSTGRES_CONTAINER" psql -U postgres -d "$DB_NAME" -c "
    GRANT ALL ON SCHEMA public TO $DB_USER;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $DB_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $DB_USER;
"

# Import database if dump file exists
if [ -f "deploy/staging/database/carsigo_staging.sql" ]; then
    log "Importing database from dump file..."
    docker exec -i "$POSTGRES_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" < deploy/staging/database/carsigo_staging.sql
    log "Database imported successfully"
else
    log "No database dump file found, running migrations instead..."
    
    # Run Laravel migrations
    if [ -f "artisan" ]; then
        log "Running Laravel migrations..."
        docker exec carsigo_staging_app php artisan migrate --force --env=staging
        
        # Seed database
        log "Seeding database..."
        docker exec carsigo_staging_app php artisan db:seed --force --env=staging
    else
        warning "Laravel artisan not found, skipping migrations"
    fi
fi

# Create backup user for automated backups
log "Creating backup user..."
docker exec "$POSTGRES_CONTAINER" psql -U postgres -c "
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'backup_user') THEN
            CREATE USER backup_user WITH PASSWORD 'backup_password_here';
        END IF;
    END
    \$\$;
    
    GRANT CONNECT ON DATABASE $DB_NAME TO backup_user;
    GRANT USAGE ON SCHEMA public TO backup_user;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO backup_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO backup_user;
" || {
    warning "Failed to create backup user"
}

# Setup automated backups
log "Setting up automated backups..."
cat > /etc/cron.d/carsigo-staging-backup << EOF
# CarSiGo Staging PostgreSQL Backup
0 2 * * * root /usr/local/bin/backup-carsigo-staging-postgres.sh
EOF

# Create backup script
cat > /usr/local/bin/backup-carsigo-staging-postgres.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/carsigo-staging/database"
DB_NAME="carsigo_staging"
DB_USER="backup_user"
DB_PASSWORD="backup_password_here"
POSTGRES_CONTAINER="carsigo_staging_postgres"
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

# Create backup
BACKUP_FILE="$BACKUP_DIR/carsigo_staging_$(date +%Y%m%d_%H%M%S).sql"
docker exec "$POSTGRES_CONTAINER" pg_dump -U "$DB_USER" -d "$DB_NAME" > "$BACKUP_FILE"

# Compress backup
gzip "$BACKUP_FILE"

# Remove old backups
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
EOF

chmod +x /usr/local/bin/backup-carsigo-staging-postgres.sh

# Test database connection
log "Testing database connection..."
if docker exec "$POSTGRES_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
    log "✅ Database connection test passed"
else
    error "❌ Database connection test failed"
    exit 1
fi

# Show database information
log "Database information:"
docker exec "$POSTGRES_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
    SELECT 
        datname as 'Database',
        encoding as 'Encoding',
        collcollate as 'Collation'
    FROM pg_database 
    WHERE datname = '$DB_NAME';
"

# Show tables
log "Tables in database:"
docker exec "$POSTGRES_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "\dt"

# Show database size
log "Database size:"
docker exec "$POSTGRES_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
    SELECT 
        pg_database_size('$DB_NAME') as size_bytes,
        pg_size_pretty(pg_database_size('$DB_NAME')) as size_pretty;
"

log "🎉 PostgreSQL setup completed successfully!"
log ""
echo "=== Database Setup Summary ==="
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Container: $POSTGRES_CONTAINER"
echo "Port: 5433"
echo "Backup Schedule: Daily at 2:00 AM"
echo "Backup Retention: $RETENTION_DAYS days"
echo "==============================="

exit 0
