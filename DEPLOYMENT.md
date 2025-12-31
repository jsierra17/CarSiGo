# 🚀 CarSiGo - Guía de Despliegue a Staging

## 📋 **Resumen del Despliegue**

Hemos configurado un entorno de staging completo y profesional para CarSiGo con:

### 🏗️ **Infraestructura Completa**
- **Backend Laravel**: PHP 8.3 + Nginx + PostgreSQL 15 + Redis 7
- **Frontend Flutter**: Web + Android + iOS builds
- **Docker**: Contenerización completa con Docker Compose
- **Monitoring**: Prometheus + Grafana + AlertManager
- **SSL**: Configuración HTTPS completa
- **Automatización**: Scripts de despliegue y mantenimiento

---

## 📁 **Estructura Creada**

```
deploy/staging/
├── docker-compose.yml          # 🐳 Todos los servicios
├── Dockerfile                  # 🐘 Laravel app
├── nginx/
│   ├── nginx.conf             # 🌐 Servidor web
│   └── sites/carsigo-staging.conf
├── scripts/
│   ├── deploy.sh              # 🚀 Script principal
│   ├── setup-postgres.sh      # 🗄️ Configuración BD PostgreSQL
│   ├── build-flutter.sh       # 📱 Build Flutter
│   └── monitoring-setup.sh   # 📊 Monitoreo
└── README.md                  # 📖 Documentación
```

---

## 🎯 **Características del Entorno**

### 🔐 **Seguridad**
- SSL/TLS configurado
- Headers de seguridad
- Variables de entorno aisladas
- Backups automáticos
- Health checks cada 5 minutos

### 📊 **Monitoreo**
- **Prometheus**: Métricas en tiempo real
- **Grafana**: Dashboards visuales
- **AlertManager**: Notificaciones automáticas
- **Logs**: Centralizados y rotados

### 🚀 **Performance**
- OPcache para PHP
- Redis para cache
- Gzip en Nginx
- Cache de archivos estáticos
- Optimización de consultas

---

## 🌐 **URLs de Acceso**

### **Aplicación**
- **HTTP**: `http://localhost:8080`
- **HTTPS**: `https://localhost:8443`
- **API**: `http://localhost:8080/api`
- **Health**: `http://localhost:8080/health`

### **Monitoreo**
- **Prometheus**: `http://localhost:9090`
- **Grafana**: `http://localhost:3000` (admin/staging_admin_password)
- **AlertManager**: `http://localhost:9093`

### **Base de Datos**
- **PostgreSQL**: localhost:5433
- **Redis**: localhost:6380

---

## 🛠️ **Pasos para Desplegar**

### **1. Preparar Entorno**
```bash
# Copiar configuración
cp .env.staging .env

# Editar variables de entorno
nano .env
```

### **2. Desplegar Backend**
```bash
# Ejecutar script principal
sudo ./deploy/staging/scripts/deploy.sh main

# Configurar base de datos PostgreSQL
sudo ./deploy/staging/scripts/setup-postgres.sh
```

### **3. Build Frontend**
```bash
# Build Flutter para todas las plataformas
./deploy/staging/scripts/build-flutter.sh all
```

### **4. Configurar Monitoreo**
```bash
# Setup completo de monitoreo
sudo ./deploy/staging/scripts/monitoring-setup.sh
```

---

## 📱 **Flutter Builds**

### **Plataformas Soportadas**
- **Android**: APK + AAB (Google Play)
- **iOS**: IPA (App Store)
- **Web**: Aplicación web responsive

### **Archivos Generados**
```
builds/
├── android/
│   ├── carsigo-staging.apk    # 📱 APK Android
│   └── carsigo-staging.aab    # 📦 Bundle Android
├── ios/
│   └── carsigo-staging.ipa    # 🍎 IPA iOS
└── web/
    └── (todos los archivos web) # 🌐 Web app
```

---

## 🔧 **Configuración Clave**

### **Variables de Entorno Principales**
```bash
APP_ENV=staging
APP_URL=https://staging.carsigo.com

DB_CONNECTION=pgsql
DB_HOST=staging-db.carsigo.com
DB_PORT=5432
DB_DATABASE=carsigo_staging
DB_USERNAME=staging_user

CACHE_DRIVER=redis
REDIS_HOST=staging-redis.carsigo.com

WOMPI_PUBLIC_KEY=pub_staging_xxxx
GOOGLE_MAPS_API_KEY=AIzaSy_staging_key
```

### **SSL Certificates**
Colocar en: `deploy/staging/ssl/`
- `carsigo_staging.crt`
- `carsigo_staging.key`

---

## 📊 **Métricas y Alertas**

### **Alertas Configuradas**
- ⚠️ **High Error Rate** (>10% errores)
- ⚠️ **High Response Time** (>2s 95th percentile)
- 🚨 **Database Down**
- 🚨 **Redis Down**
- ⚠️ **High Memory Usage** (>90%)
- ⚠️ **High CPU Usage** (>80%)
- 🚨 **Low Disk Space** (<10%)

### **Health Checks Automáticos**
- Estado de contenedores
- Health endpoint de la app
- Conexión a base de datos
- Espacio en disco

---

## 🔄 **Proceso de Despliegue Automático**

El script `deploy.sh` realiza:

1. **📦 Backup**: Copia de seguridad del deployment actual
2. **📥 Code**: Pull latest changes from Git
3. **📦 Dependencies**: Install PHP y Node dependencies
4. **🔨 Build**: Build frontend assets
5. **🗄️ Database**: Run migrations y seeds
6. **🧹 Cache**: Clear y optimize caches
7. **🔄 Services**: Restart all containers
8. **✅ Health**: Perform health checks

---

## 🐛 **Troubleshooting**

### **Comandos Útiles**
```bash
# Ver logs de contenedores
docker-compose logs [container_name]

# Ver estado de todos los servicios
docker-compose ps

# Reiniciar un servicio específico
docker-compose restart [service_name]

# Health check manual
sudo /usr/local/bin/carsigo-staging-health-check.sh
```

### **Logs Importantes**
- **Deployment**: `/var/log/carsigo-staging-deploy.log`
- **Application**: `/var/log/carsigo-staging/`
- **Database**: `/var/log/carsigo-staging-db-setup.log`

---

## 📈 **Performance y Optimización**

### **Optimizaciones Implementadas**
- ✅ PHP OPcache habilitado
- ✅ Redis cache configurado
- ✅ Nginx gzip compression
- ✅ Static file caching (1 año)
- ✅ Database query optimization
- ✅ Container resource limits

### **Métricas de Performance**
- Response time monitoring
- Error rate tracking
- Resource usage alerts
- Performance dashboards en Grafana

---

## 🔄 **Backups Automáticos**

### **Database**
- **Frecuencia**: Diaria a las 2:00 AM
- **Retención**: 7 días
- **Ubicación**: `/var/backups/carsigo-staging/database/`

### **Application**
- **Frecuencia**: Semanal
- **Retención**: 30 días
- **Ubicación**: `/var/backups/carsigo-staging/`

---

## 🎯 **Estado Actual del Despliegue**

### ✅ **Completado**
- 🏗️ Infraestructura Docker completa
- 🌐 Configuración Nginx + SSL
- 🗄️ PostgreSQL + Redis setup
- 📊 Stack de monitoreo
- 🚀 Scripts de automatización
- 📱 Build pipeline para Flutter
- 📋 Documentación completa

### 🔄 **Listo para Usar**
1. **Configurar variables de entorno** (`.env`)
2. **Ejecutar scripts de despliegue**
3. **Probar aplicación en staging**
4. **Configurar dominio real**
5. **Setup SSL certificates**
6. **Monitorear con Grafana**

---

## 🚀 **Siguientes Pasos**

1. **Ejecutar despliegue** con los scripts proporcionados
2. **Configurar dominio** staging.carsigo.com
3. **Setup SSL** con Let's Encrypt
4. **Probar integración** backend-frontend
5. **Validar monitoreo** y alertas
6. **Documentar proceso** para producción

---

**🎉 El entorno de staging está 100% configurado y listo para desplegar!**

Para comenzar, simplemente ejecuta:
```bash
sudo ./deploy/staging/scripts/deploy.sh main
```
