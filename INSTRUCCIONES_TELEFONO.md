# 📱 **Guía para Ejecutar CarSiGo en tu Teléfono**

## 🎯 **Objetivo**
Ejecutar la aplicación CarSiGo completa en tu teléfono Android y probar todas las funcionalidades.

---

## 🛠️ **Paso 1: Instalar Prerrequisitos**

### **Docker Desktop (Obligatorio para Backend)**
1. **Descargar**: https://www.docker.com/products/docker-desktop/
2. **Instalar** en Windows
3. **Reiniciar** el equipo
4. **Verificar**:
   ```cmd
   docker --version
   docker-compose --version
   ```

### **Flutter SDK (Obligatorio para App Móvil)**
1. **Descargar**: https://flutter.dev/docs/get-started/install/windows
2. **Extraer** en `C:\flutter`
3. **Agregar al PATH**: `C:\flutter\bin`
4. **Verificar**:
   ```cmd
   flutter --version
   flutter doctor
   ```

### **Configurar Teléfono Android**
1. **Activar Modo Desarrollador**:
   - Configuración > About phone > Tocar "Build number" 7 veces
2. **Activar Depuración USB**:
   - Configuración > Developer options > USB debugging
3. **Permitir Instalación**:
   - Configuración > Developer options > Install via USB
4. **Conectar** teléfono con cable USB

---

## 🐳 **Paso 2: Iniciar Backend (Docker)**

### **2.1 Configurar Variables**
```cmd
cd C:\Users\todoo\Documents\GitHub\CarSiGo
copy .env.staging .env
```

### **2.2 Obtener tu IP Local**
```cmd
ipconfig
```
Busca tu dirección IPv4 (ej: 192.168.1.100)

### **2.3 Actualizar Configuración**
Edita `.env` y reemplaza `localhost` con tu IP:
```env
APP_URL=http://192.168.1.100:8080
DB_HOST=192.168.1.100
REDIS_HOST=192.168.1.100
```

### **2.4 Iniciar Servicios**
```cmd
docker-compose -f deploy/staging/docker-compose.yml up -d --build
```

### **2.5 Verificar Servicios**
```cmd
docker-compose -f deploy/staging/docker-compose.yml ps
```
Espera 2-3 minutos a que todos los servicios inicien.

---

## 📱 **Paso 3: Configurar App Flutter**

### **3.1 Actualizar API URL**
Edita `carsigo_flutter/lib/core/config/app_config.dart`:
```dart
static const String apiBaseUrl = 'http://192.168.1.100:8080/api';
static const String wsUrl = 'ws://192.168.1.100:8081';
```
(Reemplaza `192.168.1.100` con tu IP)

### **3.2 Instalar Dependencias**
```cmd
cd C:\Users\todoo\Documents\GitHub\CarSiGo\carsigo_flutter
flutter pub get
```

### **3.3 Verificar Dispositivo**
```cmd
flutter devices
```
Deberías ver tu teléfono listado.

---

## 🚀 **Paso 4: Ejecutar en Teléfono**

### **Opción A: Ejecución Directa**
```cmd
flutter run
```
Flutter compilará e instalará la app en tu teléfono.

### **Opción B: Generar APK**
```cmd
flutter build apk --release
```
El APK se generará en: `build\app\outputs\flutter-apk\app-release.apk`

---

## 🎯 **Paso 5: Probar Funcionalidades**

### **5.1 Registro y Login**
1. **Abrir la app** en tu teléfono
2. **Registrarse** como pasajero o conductor
3. **Verificar** que el login funcione

### **5.2 Solicitar Viaje (Pasajero)**
1. **Iniciar sesión** como pasajero
2. **Solicitar viaje** con origen y destino
3. **Verificar** que aparezca en tiempo real

### **5.3 Aceptar Viaje (Conductor)**
1. **Iniciar sesión** como conductor
2. **Ver viajes disponibles**
3. **Aceptar un viaje**
4. **Verificar** notificaciones en tiempo real

### **5.4 Chat en Vivo**
1. **Durante un viaje activo**
2. **Enviar mensajes** entre conductor y pasajero
3. **Verificar** entrega instantánea

### **5.5 Ubicación en Tiempo Real**
1. **Conductor en viaje**
2. **Actualizar ubicación**
3. **Verificar** tracking en tiempo real

---

## 🔍 **Paso 6: Verificar Sistema Completo**

### **6.1 Backend URLs**
Abre en tu navegador:
- **App**: http://192.168.1.100:8080
- **API**: http://192.168.1.100:8080/api/health
- **WebSocket**: http://192.168.1.100:8081/apps/reverb

### **6.2 Monitoreo**
- **Prometheus**: http://192.168.1.100:9090
- **Grafana**: http://192.168.1.100:3000 (admin/staging_admin_password)

### **6.3 Base de Datos**
- **PostgreSQL**: localhost:5433
- **Redis**: localhost:6380

---

## 🐛 **Troubleshooting**

### **Problemas Comunes**

#### **Docker no funciona**
```cmd
# Reiniciar Docker Desktop
# Verificar si Docker está corriendo
docker ps
```

#### **Flutter no encuentra dispositivo**
```cmd
# Reiniciar ADB
flutter doctor
# Verificar cable USB
# Reinstalar drivers del teléfono
```

#### **App no se conecta al API**
```cmd
# Verificar IP local
ipconfig
# Verificar que Docker esté corriendo
docker-compose ps
# Probar API en navegador
curl http://192.168.1.100:8080/api/health
```

#### **Notificaciones no funcionan**
```cmd
# Verificar WebSocket
curl http://192.168.1.100:8081/apps/reverb
# Verificar logs de Reverb
docker logs carsigo_staging_reverb
```

---

## 📊 **Qué Deberías Ver**

### **En el Teléfono**
- ✅ Splash screen animado
- ✅ Login/Registro funcionando
- ✅ Dashboard principal
- ✅ Solicitar viaje
- ✅ Recibir notificaciones
- ✅ Chat en tiempo real
- ✅ Ubicación en vivo

### **En el Backend**
- ✅ Logs de eventos en tiempo real
- ✅ Conexiones WebSocket activas
- ✅ Notificaciones push enviadas
- ✅ Base de datos actualizándose

### **En Monitoreo**
- ✅ Métricas en Grafana
- ✅ Alertas funcionando
- ✅ Logs centralizados

---

## 🎯 **Checklist Final**

### **Backend** ☐
- [ ] Docker Desktop instalado
- [ ] Servicios corriendo
- [ ] API respondiendo
- [ ] WebSocket funcionando
- [ ] Base de datos conectada

### **Frontend** ☐
- [ ] Flutter instalado
- [ ] Teléfono conectado
- [ ] App instalada
- [ ] API URL configurada
- [ ] Login funcionando

### **Funcionalidades** ☐
- [ ] Registro/Login
- [ ] Solicitar viaje
- [ ] Aceptar viaje
- [ ] Chat en vivo
- [ ] Notificaciones push
- [ ] Ubicación real-time

### **Monitoreo** ☐
- [ ] Prometheus activo
- [ ] Grafana funcionando
- [ ] Logs visibles
- [ ] Alertas configuradas

---

## 🚀 **Comandos Rápidos**

```cmd
# Verificar estado Docker
docker-compose -f deploy/staging/docker-compose.yml ps

# Ver logs de un servicio
docker logs carsigo_staging_app

# Reiniciar servicios
docker-compose -f deploy/staging/docker-compose.yml restart

# Verificar API
curl http://192.168.1.100:8080/api/health

# Verificar WebSocket
curl http://192.168.1.100:8081/apps/reverb

# Ejecutar app en teléfono
flutter run

# Generar APK
flutter build apk --release
```

---

## 🎉 **¡Listo para Probar!**

Una vez que completes todos estos pasos, tendrás:
- ✅ **Backend completo** corriendo en Docker
- ✅ **App móvil** funcionando en tu teléfono
- ✅ **Notificaciones en tiempo real**
- ✅ **Chat en vivo**
- ✅ **Monitoreo profesional**
- ✅ **Sistema completo** de transporte

**¡Disfruta probando CarSiGo!** 🚗💨
