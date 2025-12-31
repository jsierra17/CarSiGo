#!/bin/bash

# CarSiGo Staging Deployment Script
# Usage: ./deploy.sh [branch]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BRANCH=${1:-main}
PROJECT_DIR="/var/www/carsigo-staging"
BACKUP_DIR="/var/backups/carsigo-staging"
LOG_FILE="/var/log/carsigo-staging-deploy.log"

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

# Create necessary directories
mkdir -p "$PROJECT_DIR"
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

log "Starting CarSiGo Staging Deployment"
log "Branch: $BRANCH"
log "Project Directory: $PROJECT_DIR"

# Backup current deployment if exists
if [ -d "$PROJECT_DIR/.git" ]; then
    log "Creating backup of current deployment..."
    BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR/$BACKUP_NAME"
    cp -r "$PROJECT_DIR" "$BACKUP_DIR/$BACKUP_NAME/"
    log "Backup created: $BACKUP_DIR/$BACKUP_NAME"
fi

# Clone or pull latest code
if [ ! -d "$PROJECT_DIR/.git" ]; then
    log "Cloning repository..."
    git clone https://github.com/your-username/CarSiGo.git "$PROJECT_DIR"
else
    log "Pulling latest changes..."
    cd "$PROJECT_DIR"
    git fetch origin
    git reset --hard origin/"$BRANCH"
    git clean -fd
fi

cd "$PROJECT_DIR"
git checkout "$BRANCH"
log "Checked out branch: $BRANCH"

# Copy staging environment file
if [ ! -f "$PROJECT_DIR/.env" ]; then
    log "Setting up environment file..."
    cp "$PROJECT_DIR/.env.staging" "$PROJECT_DIR/.env"
    
    # Generate app key if not exists
    if ! grep -q "APP_KEY=base64:" "$PROJECT_DIR/.env"; then
        log "Generating application key..."
        php artisan key:generate --force
    fi
else
    log "Environment file already exists, skipping..."
fi

# Install dependencies
log "Installing PHP dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction

# Install Node dependencies if needed
if [ -f "package.json" ]; then
    log "Installing Node dependencies..."
    npm ci --production
fi

# Build frontend assets
if [ -f "webpack.mix.js" ] || [ -f "vite.config.js" ]; then
    log "Building frontend assets..."
    npm run build
fi

# Set proper permissions
log "Setting permissions..."
chown -R www-data:www-data "$PROJECT_DIR"
chmod -R 755 "$PROJECT_DIR"
chmod -R 775 "$PROJECT_DIR/storage"
chmod -R 775 "$PROJECT_DIR/bootstrap/cache"

# Clear caches
log "Clearing caches..."
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Run database migrations
log "Running database migrations..."
php artisan migrate --force

# Seed database if needed
if [ "$BRANCH" = "main" ] || [ "$1" = "--seed" ]; then
    log "Seeding database..."
    php artisan db:seed --force
fi

# Optimize for production
log "Optimizing application..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Restart services
log "Restarting services..."
docker-compose -f deploy/staging/docker-compose.yml down
docker-compose -f deploy/staging/docker-compose.yml up -d --build

# Wait for services to be ready
log "Waiting for services to be ready..."
sleep 30

# Health check
log "Performing health check..."
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    log "✅ Health check passed"
else
    error "❌ Health check failed"
    exit 1
fi

# Run tests if available
if [ -f "artisan" ] && php artisan | grep -q "test"; then
    log "Running tests..."
    php artisan test --env=staging
fi

# Clean up old backups (keep last 5)
log "Cleaning up old backups..."
cd "$BACKUP_DIR"
ls -t | tail -n +6 | xargs -r rm -rf

log "🚀 Deployment completed successfully!"
log "Application is available at: http://localhost:8080"
log "HTTPS available at: https://localhost:8443"

# Display deployment summary
echo ""
echo "=== Deployment Summary ==="
echo "Branch: $BRANCH"
echo "Environment: staging"
echo "URL: http://localhost:8080"
echo "HTTPS URL: https://localhost:8443"
echo "Database: MySQL (localhost:3307)"
echo "Cache: Redis (localhost:6380)"
echo "Logs: $LOG_FILE"
echo "=========================="

# Send notification (optional)
if command -v slack-cli &> /dev/null; then
    slack-cli send "🚀 CarSiGo Staging Deployment Completed Successfully!"
fi

exit 0
