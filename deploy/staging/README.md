# CarSiGo Staging Environment

This directory contains all the configuration and scripts needed to deploy the CarSiGo application to a staging environment.

## 🏗️ Architecture

The staging environment consists of:

- **Backend**: Laravel application with PHP-FPM
- **Frontend**: Flutter web application
- **Database**: MySQL 8.0
- **Cache**: Redis 7
- **Web Server**: Nginx
- **Monitoring**: Prometheus + Grafana + AlertManager
- **Containerization**: Docker & Docker Compose

## 📁 Directory Structure

```
deploy/staging/
├── docker-compose.yml          # Main application containers
├── Dockerfile                  # Laravel application Dockerfile
├── nginx/
│   ├── nginx.conf             # Nginx main configuration
│   └── sites/
│       └── carsigo-staging.conf # Site configuration
├── scripts/
│   ├── deploy.sh              # Main deployment script
│   ├── setup-database.sh      # Database setup script
│   ├── build-flutter.sh       # Flutter build script
│   └── monitoring-setup.sh   # Monitoring setup script
├── database/
│   └── carsigo_staging.sql    # Database dump (optional)
└── README.md                  # This file
```

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Git
- Make (optional)
- SSL certificates (for HTTPS)

### 1. Environment Setup

Copy the staging environment file:

```bash
cp .env.staging .env
```

Edit the environment variables:

```bash
nano .env
```

### 2. Deploy the Application

Run the main deployment script:

```bash
chmod +x deploy/staging/scripts/deploy.sh
sudo deploy/staging/scripts/deploy.sh main
```

### 3. Setup Database

```bash
chmod +x deploy/staging/scripts/setup-database.sh
sudo deploy/staging/scripts/setup-database.sh
```

### 4. Build Flutter Application

```bash
chmod +x deploy/staging/scripts/build-flutter.sh
deploy/staging/scripts/build-flutter.sh all
```

### 5. Setup Monitoring

```bash
chmod +x deploy/staging/scripts/monitoring-setup.sh
sudo deploy/staging/scripts/monitoring-setup.sh
```

## 🌐 Access URLs

After deployment, the application will be available at:

- **HTTP**: http://localhost:8080
- **HTTPS**: https://localhost:8443
- **Flutter Web**: http://localhost:8080/web
- **API**: http://localhost:8080/api

### Monitoring URLs

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/staging_admin_password)
- **AlertManager**: http://localhost:9093

### Database Access

- **MySQL**: localhost:3307
- **Redis**: localhost:6380

## 🔧 Configuration

### Environment Variables

Key environment variables in `.env.staging`:

```bash
# App Configuration
APP_ENV=staging
APP_URL=https://staging.carsigo.com

# Database
DB_CONNECTION=mysql
DB_HOST=staging-db.carsigo.com
DB_DATABASE=carsigo_staging
DB_USERNAME=staging_user
DB_PASSWORD=staging_password_here

# Cache
CACHE_DRIVER=redis
REDIS_HOST=staging-redis.carsigo.com

# Payment (Wompi)
WOMPI_PUBLIC_KEY=pub_staging_xxxx
WOMPI_PRIVATE_KEY=prv_staging_xxxx

# Google Maps
GOOGLE_MAPS_API_KEY=AIzaSy_staging_google_maps_key
```

### SSL Configuration

Place SSL certificates in `deploy/staging/ssl/`:

- `carsigo_staging.crt` - SSL certificate
- `carsigo_staging.key` - Private key

### Nginx Configuration

The Nginx configuration includes:

- HTTP/HTTPS support
- PHP-FPM integration
- Static file caching
- Security headers
- Gzip compression
- Health checks

## 📊 Monitoring

### Metrics Collected

- **Application**: HTTP requests, response times, error rates
- **Database**: Connection status, query performance
- **Cache**: Redis operations, memory usage
- **System**: CPU, memory, disk usage
- **Docker**: Container status and resource usage

### Alerts Configured

- High error rates
- High response times
- Database/Redis down
- High resource usage
- Low disk space
- Container failures

### Health Checks

Automated health checks run every 5 minutes:

- Container status
- Application health endpoint
- Database connectivity
- Disk space

## 🔄 Deployment Process

### Automatic Deployment

The deployment script automatically:

1. **Backup**: Creates backup of current deployment
2. **Code**: Pulls latest changes from Git
3. **Dependencies**: Installs PHP and Node dependencies
4. **Build**: Builds frontend assets
5. **Database**: Runs migrations and seeds
6. **Cache**: Clears and optimizes caches
7. **Services**: Restarts all containers
8. **Health**: Performs health checks

### Manual Steps

If you need to run steps manually:

```bash
# Pull latest code
git pull origin main

# Install dependencies
composer install --no-dev --optimize-autoloader
npm ci --production

# Build assets
npm run build

# Run migrations
php artisan migrate --force

# Clear caches
php artisan cache:clear
php artisan config:cache

# Restart services
docker-compose down
docker-compose up -d --build
```

## 🐛 Troubleshooting

### Common Issues

1. **Container won't start**
   ```bash
   docker-compose logs [container_name]
   ```

2. **Database connection failed**
   ```bash
   docker exec carsigo_staging_mysql mysql -u staging_user -p
   ```

3. **Nginx 502 error**
   ```bash
   docker exec carsigo_staging_nginx nginx -t
   ```

4. **Permission issues**
   ```bash
   sudo chown -R www-data:www-data /var/www/html
   sudo chmod -R 755 /var/www/html
   ```

### Logs

- **Application**: `/var/log/carsigo-staging/`
- **Nginx**: `docker logs carsigo_staging_nginx`
- **MySQL**: `docker logs carsigo_staging_mysql`
- **Redis**: `docker logs carsigo_staging_redis`
- **Deployment**: `/var/log/carsigo-staging-deploy.log`

### Health Check

Run manual health check:

```bash
sudo /usr/local/bin/carsigo-staging-health-check.sh
```

## 📱 Flutter Application

### Build Platforms

The Flutter build script supports:

- **Android**: APK and AAB files
- **iOS**: IPA file (requires Xcode)
- **Web**: Web application

### Build Commands

```bash
# Build all platforms
./build-flutter.sh all

# Build specific platform
./build-flutter.sh android
./build-flutter.sh ios
./build-flutter.sh web
```

### Build Outputs

- **Android**: `builds/android/carsigo-staging.apk`
- **iOS**: `builds/ios/carsigo-staging.ipa`
- **Web**: `builds/web/`

## 🔒 Security

### Security Measures

- HTTPS enforced
- Security headers configured
- Database credentials encrypted
- Regular security updates
- Container security scanning
- Access logs monitored

### SSL Certificates

For production, use Let's Encrypt:

```bash
sudo certbot --nginx -d staging.carsigo.com
```

## 📈 Performance

### Optimization

- PHP OPcache enabled
- Redis caching configured
- Nginx gzip compression
- Static file caching
- Database query optimization
- Container resource limits

### Monitoring

- Response time monitoring
- Error rate tracking
- Resource usage alerts
- Performance dashboards

## 🔄 Backup and Recovery

### Automated Backups

- **Database**: Daily at 2:00 AM
- **Files**: Weekly
- **Retention**: 7 days for database, 30 days for files

### Manual Backup

```bash
# Database backup
docker exec carsigo_staging_mysql mysqldump -u staging_user -p carsigo_staging > backup.sql

# Application backup
tar -czf app-backup.tar.gz /var/www/html
```

### Recovery

```bash
# Restore database
docker exec -i carsigo_staging_mysql mysql -u staging_user -p carsigo_staging < backup.sql

# Restore application
tar -xzf app-backup.tar.gz -C /var/www/
```

## 📞 Support

### Contact

- **Email**: admin@carsigo.com
- **Documentation**: https://docs.carsigo.com
- **Issues**: https://github.com/your-org/CarSiGo/issues

### Emergency

For critical issues:

1. Check health logs: `/var/log/carsigo-staging/health-check.log`
2. Run manual health check: `/usr/local/bin/carsigo-staging-health-check.sh`
3. Check monitoring dashboards
4. Contact on-call engineer

---

**Last Updated**: $(date)
**Version**: 1.0.0
**Environment**: Staging
