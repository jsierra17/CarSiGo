# 🚗 CarSiGo - Plataforma de Transporte Bajo Demanda

**Sistema inteligente de solicitud y gestión de viajes para El Carmen de Bolívar, Colombia**

![Status](https://img.shields.io/badge/Status-Phase%203%20Complete-green)
![PHP](https://img.shields.io/badge/PHP-8.3-blue)
![Laravel](https://img.shields.io/badge/Laravel-11-red)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13%2B-336791)
![License](https://img.shields.io/badge/License-Proprietary-orange)

---

## 📊 Estado del Proyecto

```
✅ FASE 1: Base de Datos        - COMPLETADA
✅ FASE 2: Autenticación        - COMPLETADA
✅ FASE 3: APIs REST            - COMPLETADA
⏳ FASE 4: Integración LLM+MCP  - PRÓXIMO
⏳ FASE 5: Aplicación Mobile    - PRÓXIMO
⏳ FASE 6: Testing Real         - PRÓXIMO
⏳ FASE 7: Lanzamiento          - PRÓXIMO
```

---

## 🎯 Características Principales

### 🚗 Para Pasajeros
- ✅ Solicitar viaje con ubicación GPS
- ✅ Ver conductores disponibles en tiempo real
- ✅ Seguimiento en vivo del conductor
- ✅ Pagar de múltiples formas
- ✅ Calificar conductor y viaje
- ✅ Historial de viajes
- ✅ Soporte por tickets

### 👨‍✈️ Para Conductores
- ✅ Recibir solicitudes de viaje
- ✅ Reportar ubicación en tiempo real
- ✅ Aceptar/rechazar viajes
- ✅ Ver ganancias y comisiones
- ✅ Historial de calificaciones
- ✅ Gestión de documentos
- ✅ Conectarse/desconectarse

### 👨‍💼 Para Administración
- ✅ Gestionar conductores
- ✅ Monitorear transacciones
- ✅ Ver estadísticas
- ✅ Gestionar soporte
- ✅ Configuración del sistema

---

## 🏗️ Arquitectura

### Tecnología Stack

| Componente | Tecnología |
|-----------|-----------|
| **Backend** | Laravel 11 + PHP 8.3 |
| **Base de Datos** | PostgreSQL 13+ |
| **Autenticación** | Laravel Sanctum (Tokens) |
| **ORM** | Eloquent |
| **API** | RESTful Architecture |
| **Geolocalización** | Haversine Formula |

### Base de Datos

```
14 tablas ➜ 12 modelos ➜ 100+ relaciones
├─ users           (Usuarios del sistema)
├─ conductores     (Perfiles de conductores)
├─ vehiculos       (Vehículos registrados)
├─ viajes          (Solicitudes de viaje)
├─ ubicaciones     (Tracking GPS)
├─ pagos           (Transacciones)
├─ comisiones      (Comisiones ganadas)
├─ promociones     (Códigos descuento)
├─ emergencias     (SOS reports)
├─ soporte_tickets (Tickets de soporte)
├─ soporte_respuestas (Respuestas de soporte)
├─ logs_sistema    (Auditoría)
├─ configuracion   (Parámetros del sistema)
└─ personal_access_tokens (Sanctum auth)
```

---

## 📡 API REST - 46+ Endpoints

### Viajes (11 endpoints)
```
POST   /api/viajes                    ← Solicitar viaje
GET    /api/viajes/disponibles        ← Ver sin conductor
PATCH  /api/viajes/{id}/aceptar       ← Aceptar
PATCH  /api/viajes/{id}/iniciar       ← Iniciar
PATCH  /api/viajes/{id}/completar     ← Completar
PATCH  /api/viajes/{id}/cancelar      ← Cancelar
POST   /api/viajes/{id}/calificar     ← Calificar
...y 4 más
```

### Ubicaciones (5 endpoints)
```
POST   /api/ubicaciones/reportar              ← Enviar ubicación
GET    /api/ubicaciones/conductores/cercanos  ← Buscar por radio
GET    /api/ubicaciones/viajes/{id}/historico ← Ruta del viaje
...y 2 más
```

### Pagos (6 endpoints)
```
POST   /api/pagos/viajes/{id}/procesar  ← Procesar pago
GET    /api/pagos/resumen/ganancias     ← Ver ganancias
GET    /api/pagos/{id}/recibo           ← Descargar recibo
...y 3 más
```

### Conductores (10 endpoints)
```
GET    /api/conductores/mi-perfil           ← Mi perfil
PUT    /api/conductores/mi-perfil           ← Actualizar
POST   /api/conductores/documentos/subir    ← Cargar doc
GET    /api/conductores/ganancias           ← Ver ganancias
GET    /api/conductores/calificaciones      ← Ver ratings
...y 5 más
```

### Soporte (7 endpoints)
```
POST   /api/soporte/tickets                 ← Crear ticket
POST   /api/soporte/tickets/{id}/responder  ← Responder
PATCH  /api/soporte/tickets/{id}/estado     ← Cambiar estado
GET    /api/soporte/estadisticas            ← Ver stats
...y 3 más
```

---

## 🚀 Quick Start

### Instalación

```bash
# 1. Clonar repositorio
git clone <repo>
cd CarSiGo

# 2. Instalar dependencias
composer install

# 3. Configurar .env
cp .env.example .env
php artisan key:generate

# 4. Migraciones y seeding
php artisan migrate:refresh --seed

# 5. Servidor de desarrollo
php artisan serve
```

### Primeros Pasos

```bash
# 1. Login
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "pasajero1@carsigo.co",
    "password": "Pasajero@123"
  }'

# 2. Solicitar viaje
curl -X POST http://127.0.0.1:8000/api/viajes \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "origen_latitud": 10.4023,
    "origen_longitud": -75.5156,
    "destino_latitud": 10.4115,
    "destino_longitud": -75.5078,
    "origen_direccion": "Calle 1",
    "destino_direccion": "Calle 5",
    "distancia_estimada": 2.5,
    "duracion_estimada": 600
  }'
```

---

## 👥 Usuarios de Prueba

| Rol | Email | Contraseña |
|-----|-------|-----------|
| Admin | admin@carsigo.co | Admin@123 |
| Soporte | soporte@carsigo.co | Soporte@123 |
| Conductor 1 | conductor1@carsigo.co | Conductor@123 |
| Conductor 2 | conductor2@carsigo.co | Conductor@123 |
| Pasajero 1 | pasajero1@carsigo.co | Pasajero@123 |
| Pasajero 2 | pasajero2@carsigo.co | Pasajero@123 |

---

## 📚 Documentación

### Archivos de Referencia

| Archivo | Descripción |
|---------|-----------|
| [APIS_FASE_3_DOCUMENTACION.md](APIS_FASE_3_DOCUMENTACION.md) | Documentación completa de endpoints |
| [REFERENCIA_RAPIDA_ENDPOINTS.md](REFERENCIA_RAPIDA_ENDPOINTS.md) | Guía rápida con ejemplos |
| [API_RESUMEN_VISUAL.md](API_RESUMEN_VISUAL.md) | Dashboard visual del proyecto |
| [FASE_3_APIS_COMPLETADA.md](FASE_3_APIS_COMPLETADA.md) | Resumen de Fase 3 |
| [test_api.sh](test_api.sh) | Script de prueba completo |

---

## 🔐 Seguridad

✅ **Autenticación:** Laravel Sanctum (token-based)
✅ **Autorización:** Policies + Middleware
✅ **Validación:** Input sanitization en todos los endpoints
✅ **Hashing:** Bcrypt para contraseñas
✅ **Auditoría:** Sistema completo de logs
✅ **HTTPS:** Listo para HTTPS en producción

---

## 📊 Estadísticas

```
Controladores:       5
Métodos:            38
Endpoints:          46+
Líneas de Código:   2,030+
Migraciones:        15
Modelos:            12
Documentación:      1,500+ líneas
Base de Datos:      14 tablas
Usuarios Seed:      6
```

---

## 🧪 Testing

```bash
# Script de prueba completo
bash test_api.sh

# Listar rutas
php artisan route:list --path=api

# Ver migraciones
php artisan migrate:status

# Tinker (REPL)
php artisan tinker
```

---

## 🚀 Características Avanzadas

### 1. Geolocalización en Tiempo Real
- Fórmula de Haversine para cálculo de distancia
- Búsqueda de conductores por radio
- Historial de ubicaciones por viaje

### 2. Transacciones ACID
- Manejo de pagos con rollback automático
- Consistencia de datos garantizada
- Comisiones calculadas automáticamente

### 3. Sistema de Soporte Inteligente
- Tickets con número único automático
- Respuestas de staff y usuario
- Estadísticas en tiempo real
- Preparado para integración LLM

### 4. Documentos Seguros
- Almacenamiento en /storage/private/
- Validación de tipo y tamaño
- Restricción de acceso

### 5. Validaciones Multi-capa
- Validación de input
- Type hints
- Validación de enums
- Validación de coordenadas

---

## 📈 Próximas Fases

### Fase 4: Integración LLM + MCP
- Respuestas automáticas de soporte
- Análisis de feedback
- Recomendaciones inteligentes

### Fase 5: Aplicación Mobile (Flutter)
- Cliente para pasajeros
- Cliente para conductores
- Push notifications

### Fase 6: Testing Real
- Beta testing
- Ajustes de UX/UI
- Optimización

### Fase 7: Lanzamiento
- Deploy en producción
- Integración sistemas de pago
- Capacitación de usuarios

---

## 📞 Soporte & Contacto

Para reportar bugs o sugerencias:
- Crear ticket en `/api/soporte/tickets`
- Email: soporte@carsigo.co
- Teléfono: +57 (local)

---

## 📄 Licencia

Propietario - CarSiGo ® 2025

---

## 👨‍💻 Desarrollado por

**GitHub Copilot + Laravel 11**

Diciembre 2025

---

**Status:** ✅ Fase 3 Completada | Listo para Fase 4

<p align="center">
  <strong>¡Bienvenido a CarSiGo! 🚗</strong>
</p>


In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
