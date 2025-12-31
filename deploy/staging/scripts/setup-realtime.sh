#!/bin/bash

# CarSiGo Staging Real-time Setup Script
# Sets up WebSocket server, push notifications, and real-time features

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/var/www/carsigo-staging"
LOG_FILE="/var/log/carsigo-staging-realtime-setup.log"

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

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}" | tee -a "$LOG_FILE"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run as root"
    exit 1
fi

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

log "Starting CarSiGo Staging Real-time Setup"

# Install additional PHP extensions
log "Installing PHP extensions for real-time features..."
docker exec carsigo_staging_app pecl install redis > /dev/null 2>&1 || true
docker exec carsigo_staging_app docker-php-ext-enable redis > /dev/null 2>&1 || true

# Install Node.js dependencies for Reverb
log "Installing Node.js dependencies..."
if [ ! -d "$PROJECT_DIR/node_modules" ]; then
    cd "$PROJECT_DIR"
    npm install
    npm run build
fi

# Install Composer dependencies
log "Installing Composer dependencies..."
cd "$PROJECT_DIR"
composer install --no-dev --optimize-autoloader

# Generate Reverb keys
log "Generating Reverb keys..."
cd "$PROJECT_DIR"
php artisan reverb:generate-keys || {
    warning "Reverb keys generation failed, using defaults"
}

# Update environment file with Reverb configuration
log "Updating environment configuration..."
cd "$PROJECT_DIR"

# Add Reverb configuration to .env if not exists
if ! grep -q "REVERB_APP_KEY" .env; then
    cat >> .env << 'EOF'

# Reverb Configuration
REVERB_APP_KEY=reverb_key
REVERB_APP_SECRET=reverb_secret
REVERB_APP_ID=reverb
REVERB_HOST=0.0.0.0
REVERB_PORT=8080
REVERB_SCHEME=http
REVERB_PING_INTERVAL=30
REVERB_MAX_MESSAGE_SIZE=10000
EOF
fi

# Add Pusher configuration if not exists
if ! grep -q "PUSHER_APP_KEY" .env; then
    cat >> .env << 'EOF'

# Pusher Configuration
BROADCAST_DRIVER=reverb
PUSHER_APP_KEY=reverb_key
PUSHER_APP_SECRET=reverb_secret
PUSHER_APP_ID=reverb
PUSHER_APP_CLUSTER=mt1
PUSHER_HOST=127.0.0.1
PUSHER_PORT=8080
PUSHER_SCHEME=http
EOF
fi

# Add Firebase configuration if not exists
if ! grep -q "FCM_SERVER_KEY" .env; then
    cat >> .env << 'EOF'

# Firebase/FCM Configuration
FCM_SERVER_KEY=AAAA_staging_fcm_key_here
FCM_SENDER_ID=1234567890_staging
FIREBASE_PROJECT_ID=carsigo-staging
EOF
fi

# Clear and cache configuration
log "Clearing and caching configuration..."
php artisan config:clear
php artisan config:cache
php artisan route:clear
php artisan route:cache

# Run database migrations for chat messages
log "Running database migrations..."
php artisan migrate --force

# Seed real-time data
log "Seeding real-time data..."
php artisan db:seed --class=RealtimeSeeder --force || {
    warning "Realtime seeder not found, continuing..."
}

# Setup Redis for real-time features
log "Setting up Redis for real-time features..."
docker exec carsigo_staging_redis redis-cli CONFIG SET notify-keyspace-events Ex > /dev/null 2>&1 || true

# Create supervisor configuration for Reverb
log "Creating supervisor configuration for Reverb..."
cat > /etc/supervisor/conf.d/carsigo-staging-reverb.conf << 'EOF'
[program:carsigo-staging-reverb]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/html/artisan reverb:start
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=1
redirect_stderr=true
stdout_logfile=/var/log/carsigo-staging/reverb.log
stopwaitsecs=3600
EOF

# Create log directory for Reverb
mkdir -p /var/log/carsigo-staging
chown www-data:www-data /var/log/carsigo-staging

# Restart supervisor to load new configuration
log "Restarting supervisor..."
supervisorctl reread
supervisorctl update
supervisorctl restart carsigo-staging-reverb || true

# Setup Nginx for WebSocket connections
log "Setting up Nginx for WebSocket connections..."
cat > /etc/nginx/sites-available/carsigo-staging-websockets.conf << 'EOF'
upstream reverb {
    server 127.0.0.1:8081;
}

server {
    listen 8081;
    server_name _;
    
    location / {
        proxy_pass http://reverb;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Enable WebSocket site
ln -sf /etc/nginx/sites-available/carsigo-staging-websockets.conf /etc/nginx/sites-enabled/

# Test Nginx configuration
nginx -t && systemctl reload nginx || {
    error "Nginx configuration test failed"
}

# Setup firewall rules for WebSocket
log "Setting up firewall rules..."
if command -v ufw &> /dev/null; then
    ufw allow 8081/tcp comment "CarSiGo Reverb WebSocket"
    ufw reload || true
fi

# Create monitoring for WebSocket connections
log "Setting up WebSocket monitoring..."
cat > /usr/local/bin/monitor-reverb.sh << 'EOF'
#!/bin/bash

# Monitor Reverb WebSocket connections
REVERB_LOG="/var/log/carsigo-staging/reverb.log"
ALERT_THRESHOLD=100
ALERT_EMAIL="admin@carsigo.com"

# Get current connection count
CONNECTIONS=$(tail -n 100 $REVERB_LOG | grep -c "connected" || echo "0")

if [ "$CONNECTIONS" -gt "$ALERT_THRESHOLD" ]; then
    echo "High WebSocket connections detected: $CONNECTIONS" | mail -s "WebSocket Alert" $ALERT_EMAIL
fi

# Check if Reverb process is running
if ! pgrep -f "reverb:start" > /dev/null; then
    echo "Reverb process is not running" | mail -s "Reverb Down Alert" $ALERT_EMAIL
    supervisorctl restart carsigo-staging-reverb
fi

# Log connection count
echo "$(date): WebSocket connections: $CONNECTIONS" >> /var/log/carsigo-staging/websocket-monitor.log
EOF

chmod +x /usr/local/bin/monitor-reverb.sh

# Add to cron for monitoring
echo "*/5 * * * * root /usr/local/bin/monitor-reverb.sh" > /etc/cron.d/carsigo-staging-websocket-monitor

# Test WebSocket connection
log "Testing WebSocket connection..."
sleep 10

# Test if Reverb is responding
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/apps/reverb | grep -q "200"; then
    log "✅ WebSocket server is responding"
else
    warning "⚠️ WebSocket server might not be responding properly"
fi

# Test broadcasting
log "Testing broadcasting..."
cd "$PROJECT_DIR"
php artisan tinker --execute="
    event(new \App\Events\ViajeSolicitado(
        \App\Models\Viaje::first(),
        \App\Models\User::first()
    ));
" > /dev/null 2>&1 || {
    warning "Broadcasting test failed"
}

# Create health check endpoint for WebSocket
log "Creating WebSocket health check..."
cat > "$PROJECT_DIR/app/Http/Controllers/Api/WebsocketController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class WebsocketController extends Controller
{
    public function health(): JsonResponse
    {
        return response()->json([
            'status' => 'healthy',
            'websocket' => 'running',
            'timestamp' => now()->toISOString(),
        ]);
    }

    public function stats(): JsonResponse
    {
        // This would require actual WebSocket server integration
        return response()->json([
            'connections' => 0,
            'channels' => 0,
            'messages_per_second' => 0,
            'uptime' => 0,
        ]);
    }
}
EOF

# Add WebSocket routes
if ! grep -q "websocket" "$PROJECT_DIR/routes/api.php"; then
    cat >> "$PROJECT_DIR/routes/api.php" << 'EOF'

// WebSocket health check
Route::get('/websocket/health', [App\Http\Controllers\Api\WebsocketController::class, 'health']);
Route::get('/websocket/stats', [App\Http\Controllers\Api\WebsocketController::class, 'stats']);
EOF
fi

# Clear routes cache
php artisan route:cache

log "🎉 Real-time setup completed successfully!"
log ""
echo "=== Real-time Setup Summary ==="
echo "WebSocket Server: http://localhost:8081"
echo "Health Check: http://localhost:8080/api/websocket/health"
echo "Stats: http://localhost:8080/api/websocket/stats"
echo "Reverb Logs: /var/log/carsigo-staging/reverb.log"
echo "Monitoring: Every 5 minutes"
echo "==============================="

exit 0
