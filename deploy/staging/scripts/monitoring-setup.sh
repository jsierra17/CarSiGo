#!/bin/bash

# CarSiGo Staging Monitoring Setup Script
# Sets up monitoring, logging, and alerting for staging environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="carsigo-staging"
MONITORING_DIR="/opt/monitoring"
LOG_DIR="/var/log/$PROJECT_NAME"
PROMETHEUS_DIR="$MONITORING_DIR/prometheus"
GRAFANA_DIR="$MONITORING_DIR/grafana"
ALERTMANAGER_DIR="$MONITORING_DIR/alertmanager"
LOG_FILE="/var/log/carsigo-staging-monitoring-setup.log"

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

# Create directories
create_directories() {
    log "Creating monitoring directories..."
    mkdir -p "$MONITORING_DIR" "$PROMETHEUS_DIR" "$GRAFANA_DIR" "$ALERTMANAGER_DIR" "$LOG_DIR"
    mkdir -p "$MONITORING_DIR/rules"
    mkdir -p "$MONITORING_DIR/dashboards"
}

# Setup Prometheus
setup_prometheus() {
    log "Setting up Prometheus..."
    
    # Create Prometheus configuration
    cat > "$PROMETHEUS_DIR/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "/etc/prometheus/rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx-exporter:9113']

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'carsigo-app'
    static_configs:
      - targets: ['app:9000']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'docker'
    static_configs:
      - targets: ['docker-exporter:9323']
EOF

    # Create alert rules
    cat > "$MONITORING_DIR/rules/carsigo-alerts.yml" << 'EOF'
groups:
  - name: carsigo_staging_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }} seconds"

      - alert: DatabaseDown
        expr: up{job="postgres"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "PostgreSQL database is down"
          description: "PostgreSQL database has been down for more than 1 minute"

      - alert: RedisDown
        expr: up{job="redis"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Redis is down"
          description: "Redis has been down for more than 1 minute"

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value | humanizePercentage }}"

      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ $value }}%"

      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 < 10
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space"
          description: "Disk space is {{ $value }}% available"

      - alert: ContainerDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Container is down"
          description: "Container {{ $labels.instance }} has been down for more than 1 minute"
EOF

    log "✅ Prometheus configuration created"
}

# Setup Grafana
setup_grafana() {
    log "Setting up Grafana..."
    
    # Create Grafana configuration
    cat > "$GRAFANA_DIR/grafana.ini" << 'EOF'
[server]
http_port = 3000
root_url = http://localhost:3000

[database]
type = sqlite3
path = grafana.db

[security]
admin_user = admin
admin_password = staging_admin_password

[users]
allow_sign_up = false
auto_assign_org_role = Viewer

[auth.anonymous]
enabled = true
org_role = Viewer
EOF

    # Create provisioning configuration
    mkdir -p "$GRAFANA_DIR/provisioning/datasources"
    mkdir -p "$GRAFANA_DIR/provisioning/dashboards"

    # Datasource configuration
    cat > "$GRAFANA_DIR/provisioning/datasources/prometheus.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

    # Dashboard configuration
    cat > "$GRAFANA_DIR/provisioning/dashboards/dashboards.yml" << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

    log "✅ Grafana configuration created"
}

# Setup AlertManager
setup_alertmanager() {
    log "Setting up AlertManager..."
    
    # Create AlertManager configuration
    cat > "$ALERTMANAGER_DIR/alertmanager.yml" << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@carsigo.com'
  smtp_auth_username: 'alerts@carsigo.com'
  smtp_auth_password: 'smtp_password'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
  routes:
    - match:
        severity: critical
      receiver: 'critical-alerts'
    - match:
        severity: warning
      receiver: 'warning-alerts'

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://localhost:5001/'

  - name: 'critical-alerts'
    email_configs:
      - to: 'admin@carsigo.com'
        subject: '[CRITICAL] CarSiGo Staging Alert'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}

  - name: 'warning-alerts'
    email_configs:
      - to: 'dev-team@carsigo.com'
        subject: '[WARNING] CarSiGo Staging Alert'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOF

    log "✅ AlertManager configuration created"
}

# Setup Docker Compose for monitoring
setup_monitoring_docker_compose() {
    log "Setting up Docker Compose for monitoring..."
    
    cat > "$MONITORING_DIR/docker-compose.monitoring.yml" << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: carsigo_staging_prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./rules:/etc/prometheus/rules
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: carsigo_staging_grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - ./grafana/grafana.ini:/etc/grafana/grafana.ini
      - ./grafana/provisioning:/etc/grafana/provisioning
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=staging_admin_password
      - GF_USERS_ALLOW_SIGN_UP=false
    networks:
      - monitoring
    depends_on:
      - prometheus

  alertmanager:
    image: prom/alertmanager:latest
    container_name: carsigo_staging_alertmanager
    restart: unless-stopped
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - alertmanager_data:/alertmanager
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    container_name: carsigo_staging_node_exporter
    restart: unless-stopped
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    networks:
      - monitoring

  nginx-exporter:
    image: nginx/nginx-prometheus-exporter:latest
    container_name: carsigo_staging_nginx_exporter
    restart: unless-stopped
    ports:
      - "9113:9113"
    command:
      - '-nginx.scrape-uri=http://nginx:8080/nginx_status'
    networks:
      - monitoring
    depends_on:
      - nginx
      - postgres
      - redis

  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    container_name: carsigo_staging_postgres_exporter
    restart: unless-stopped
    ports:
      - "9187:9187"
    environment:
      - DATA_SOURCE_NAME=postgresql://staging_user:staging_password_here@(postgres:5432)/carsigo_staging?sslmode=disable
    networks:
      - monitoring
    depends_on:
      - postgres

  redis-exporter:
    image: oliver006/redis_exporter:latest
    container_name: carsigo_staging_redis_exporter
    restart: unless-stopped
    ports:
      - "9121:9121"
    environment:
      - REDIS_ADDR=redis://redis:6379
    networks:
      - monitoring
    depends_on:
      - redis

networks:
  monitoring:
    driver: bridge

volumes:
  prometheus_data:
    driver: local
  grafana_data:
    driver: local
  alertmanager_data:
    driver: local
EOF

    log "✅ Docker Compose for monitoring created"
}

# Setup log rotation
setup_log_rotation() {
    log "Setting up log rotation..."
    
    cat > "/etc/logrotate.d/carsigo-staging" << 'EOF'
/var/log/carsigo-staging/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
    postrotate
        docker kill -s USR1 carsigo_staging_nginx
    endscript
}

/var/log/carsigo-staging-deploy.log {
    weekly
    missingok
    rotate 12
    compress
    delaycompress
    notifempty
    create 644 root root
}

/var/log/carsigo-staging-db-setup.log {
    weekly
    missingok
    rotate 12
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

    log "✅ Log rotation configured"
}

# Setup health checks
setup_health_checks() {
    log "Setting up health checks..."
    
    cat > "/usr/local/bin/carsigo-staging-health-check.sh" << 'EOF'
#!/bin/bash

# CarSiGo Staging Health Check Script

LOG_FILE="/var/log/carsigo-staging/health-check.log"
ALERT_EMAIL="admin@carsigo.com"

# Function to log
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to send alert
send_alert() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
}

# Check if containers are running
check_containers() {
    local containers=("carsigo_staging_app" "carsigo_staging_nginx" "carsigo_staging_mysql" "carsigo_staging_redis")
    local failed_containers=()
    
    for container in "${containers[@]}"; do
        if ! docker ps --format "table {{.Names}}" | grep -q "$container"; then
            failed_containers+=("$container")
        fi
    done
    
    if [ ${#failed_containers[@]} -gt 0 ]; then
        log "CRITICAL: Containers down: ${failed_containers[*]}"
        send_alert "[CRITICAL] CarSiGo Staging - Containers Down" "The following containers are down: ${failed_containers[*]}"
        return 1
    fi
    
    return 0
}

# Check application health
check_app_health() {
    if ! curl -f -s http://localhost:8080/health > /dev/null; then
        log "CRITICAL: Application health check failed"
        send_alert "[CRITICAL] CarSiGo Staging - Application Down" "Application health check failed on http://localhost:8080/health"
        return 1
    fi
    
    return 0
}

# Check database connection
check_database() {
    if ! docker exec carsigo_staging_postgres psql -U staging_user -d carsigo_staging -c "SELECT 1;" > /dev/null 2>&1; then
        log "CRITICAL: Database connection failed"
        send_alert "[CRITICAL] CarSiGo Staging - Database Down" "Database connection failed"
        return 1
    fi
    
    return 0
}

# Check disk space
check_disk_space() {
    local usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$usage" -gt 90 ]; then
        log "WARNING: Disk usage is ${usage}%"
        send_alert "[WARNING] CarSiGo Staging - Low Disk Space" "Disk usage is ${usage}% on /"
        return 1
    fi
    
    return 0
}

# Run all checks
main() {
    local failed=0
    
    check_containers || failed=1
    check_app_health || failed=1
    check_database || failed=1
    check_disk_space || failed=1
    
    if [ $failed -eq 0 ]; then
        log "All health checks passed"
    else
        log "Some health checks failed"
    fi
    
    return $failed
}

main "$@"
EOF

    chmod +x "/usr/local/bin/carsigo-staging-health-check.sh"
    
    # Add to cron
    echo "*/5 * * * * root /usr/local/bin/carsigo-staging-health-check.sh" > /etc/cron.d/carsigo-staging-health
    
    log "✅ Health checks configured"
}

# Main execution
main() {
    log "Starting CarSiGo Staging Monitoring Setup"
    
    create_directories
    setup_prometheus
    setup_grafana
    setup_alertmanager
    setup_monitoring_docker_compose
    setup_log_rotation
    setup_health_checks
    
    # Start monitoring stack
    log "Starting monitoring stack..."
    cd "$MONITORING_DIR"
    docker-compose -f docker-compose.monitoring.yml up -d
    
    # Wait for services to start
    sleep 30
    
    log "🎉 Monitoring setup completed successfully!"
    echo ""
    echo "=== Monitoring Services ==="
    echo "Prometheus: http://localhost:9090"
    echo "Grafana: http://localhost:3000 (admin/staging_admin_password)"
    echo "AlertManager: http://localhost:9093"
    echo "Node Exporter: http://localhost:9100/metrics"
    echo "=========================="
    echo ""
    echo "Health checks running every 5 minutes"
    echo "Logs rotated daily"
    echo "Alerts configured for critical and warning levels"
}

# Run main function
main "$@"
