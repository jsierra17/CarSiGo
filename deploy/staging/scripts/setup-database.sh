#!/bin/bash

# CarSiGo Staging Database Setup Script
# Usage: ./setup-database.sh

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
DB_ROOT_PASSWORD="staging_root_password_here"
MYSQL_CONTAINER="carsigo_staging_mysql"
LOG_FILE="/var/log/carsigo-staging-db-setup.log"

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

log "Starting CarSiGo Staging Database Setup"

# Wait for MySQL container to be ready
log "Waiting for MySQL container to be ready..."
for i in {1..30}; do
    if docker exec "$MYSQL_CONTAINER" mysqladmin ping -h localhost --silent; then
        log "MySQL is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        error "MySQL container is not ready after 30 seconds"
        exit 1
    fi
    sleep 1
done

# Create database if not exists
log "Creating database: $DB_NAME"
docker exec "$MYSQL_CONTAINER" mysql -u root -p"$DB_ROOT_PASSWORD" -e "
    CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
" || {
    error "Failed to create database"
    exit 1
}

# Create user if not exists
log "Creating database user: $DB_USER"
docker exec "$MYSQL_CONTAINER" mysql -u root -p"$DB_ROOT_PASSWORD" -e "
    CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
    GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
    FLUSH PRIVILEGES;
" || {
    error "Failed to create database user"
    exit 1
}

# Import database if dump file exists
if [ -f "deploy/staging/database/carsigo_staging.sql" ]; then
    log "Importing database from dump file..."
    docker exec -i "$MYSQL_CONTAINER" mysql -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < deploy/staging/database/carsigo_staging.sql
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
docker exec "$MYSQL_CONTAINER" mysql -u root -p"$DB_ROOT_PASSWORD" -e "
    CREATE USER IF NOT EXISTS 'backup_user'@'%' IDENTIFIED BY 'backup_password_here';
    GRANT SELECT, LOCK TABLES, SHOW VIEW ON $DB_NAME.* TO 'backup_user'@'%';
    FLUSH PRIVILEGES;
" || {
    warning "Failed to create backup user"
}

# Setup automated backups
log "Setting up automated backups..."
cat > /etc/cron.d/carsigo-staging-backup << EOF
# CarSiGo Staging Database Backup
0 2 * * * root /usr/local/bin/backup-carsigo-staging-db.sh
EOF

# Create backup script
cat > /usr/local/bin/backup-carsigo-staging-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/carsigo-staging/database"
DB_NAME="carsigo_staging"
DB_USER="backup_user"
DB_PASSWORD="backup_password_here"
MYSQL_CONTAINER="carsigo_staging_mysql"
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

# Create backup
BACKUP_FILE="$BACKUP_DIR/carsigo_staging_$(date +%Y%m%d_%H%M%S).sql"
docker exec "$MYSQL_CONTAINER" mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$BACKUP_FILE"

# Compress backup
gzip "$BACKUP_FILE"

# Remove old backups
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
EOF

chmod +x /usr/local/bin/backup-carsigo-staging-db.sh

# Test database connection
log "Testing database connection..."
if docker exec "$MYSQL_CONTAINER" mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" "$DB_NAME" > /dev/null 2>&1; then
    log "✅ Database connection test passed"
else
    error "❌ Database connection test failed"
    exit 1
fi

# Show database information
log "Database information:"
docker exec "$MYSQL_CONTAINER" mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "
    SELECT 
        SCHEMA_NAME as 'Database',
        DEFAULT_CHARACTER_SET_NAME as 'Charset',
        DEFAULT_COLLATION_NAME as 'Collation'
    FROM information_schema.SCHEMATA 
    WHERE SCHEMA_NAME = '$DB_NAME';
" "$DB_NAME"

# Show tables
log "Tables in database:"
docker exec "$MYSQL_CONTAINER" mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW TABLES;" "$DB_NAME"

log "🎉 Database setup completed successfully!"
log ""
echo "=== Database Setup Summary ==="
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Container: $MYSQL_CONTAINER"
echo "Backup Schedule: Daily at 2:00 AM"
echo "Backup Retention: $RETENTION_DAYS days"
echo "==============================="

exit 0
