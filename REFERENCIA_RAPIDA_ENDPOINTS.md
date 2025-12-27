# 📖 REFERENCIA RÁPIDA DE ENDPOINTS - CarSiGo APIs

## 🔐 Autenticación

**Login:**
```bash
POST /api/auth/login
{
  "email": "conductor1@carsigo.co",
  "password": "Conductor@123"
}
```
✅ Respuesta: `{ "data": { "token": "..." } }`

---

## 🚗 VIAJES - Quick Start

### 1. Pasajero solicita viaje
```bash
POST /api/viajes
Authorization: Bearer {token}
{
  "origen_latitud": 10.4023,
  "origen_longitud": -75.5156,
  "destino_latitud": 10.4115,
  "destino_longitud": -75.5078,
  "origen_direccion": "Calle 1",
  "destino_direccion": "Calle 5",
  "distancia_estimada": 2.5,
  "duracion_estimada": 600
}
```

### 2. Conductor ve viajes disponibles
```bash
GET /api/viajes/disponibles
Authorization: Bearer {token}
```

### 3. Conductor acepta viaje
```bash
PATCH /api/viajes/{viaje}/aceptar
Authorization: Bearer {token}
{}
```

### 4. Conductor inicia viaje
```bash
PATCH /api/viajes/{viaje}/iniciar
Authorization: Bearer {token}
{}
```

### 5. Conductor completa viaje
```bash
PATCH /api/viajes/{viaje}/completar
Authorization: Bearer {token}
{
  "distancia_estimada": 2.5,
  "duracion_estimada": 600,
  "precio_total": 10000
}
```

### 6. Procesar pago
```bash
POST /api/pagos/viajes/{viaje}/procesar
Authorization: Bearer {token}
{
  "metodo_pago": "tarjeta_credito",
  "requiere_factura": true
}
```

### 7. Calificar viaje
```bash
POST /api/viajes/{viaje}/calificar
Authorization: Bearer {token}
{
  "calificacion": 5,
  "comentario": "Excelente"
}
```

---

## 📍 UBICACIONES - Quick Start

### 1. Reportar ubicación (Conductor/Pasajero)
```bash
POST /api/ubicaciones/reportar
Authorization: Bearer {token}
{
  "latitud": 10.4023,
  "longitud": -75.5156,
  "precision": 5.0,
  "proveedor": "gps"
}
```

### 2. Buscar conductores cercanos
```bash
GET /api/ubicaciones/conductores/cercanos?latitud=10.4023&longitud=-75.5156&radio=2
Authorization: Bearer {token}
```

### 3. Ver ubicaciones de un viaje
```bash
GET /api/viajes/{viaje}/ubicaciones
Authorization: Bearer {token}
```

---

## 💰 PAGOS - Quick Start

### 1. Ver pagos (Pasajero/Conductor)
```bash
GET /api/pagos
Authorization: Bearer {token}
```

### 2. Ver detalles de un pago
```bash
GET /api/pagos/{pago}
Authorization: Bearer {token}
```

### 3. Ver ganancias (Conductor)
```bash
GET /api/pagos/resumen/ganancias
Authorization: Bearer {token}
```

### 4. Descargar recibo
```bash
GET /api/pagos/{pago}/recibo
Authorization: Bearer {token}
```

### 5. Reembolsar pago (Admin)
```bash
POST /api/pagos/{pago}/reembolsar
Authorization: Bearer {token}
{
  "razon": "Error en cálculo"
}
```

---

## 👨‍✈️ CONDUCTORES - Quick Start

### 1. Ver mi perfil
```bash
GET /api/conductores/mi-perfil
Authorization: Bearer {token}
```

### 2. Actualizar perfil
```bash
PUT /api/conductores/mi-perfil
Authorization: Bearer {token}
{
  "numero_licencia": "L-1234567890",
  "fecha_vencimiento_licencia": "2028-06-30",
  "banco": "Bancolombia",
  "numero_cuenta": "45061234567890",
  "tipo_cuenta": "ahorros"
}
```

### 3. Cambiar estado (En línea/Fuera línea)
```bash
PATCH /api/conductores/mi-estado-conexion
Authorization: Bearer {token}
{
  "estado_conexion": "en_linea"
}
```

### 4. Subir documento
```bash
POST /api/conductores/documentos/subir
Authorization: Bearer {token}
Content-Type: multipart/form-data
tipo_documento=licencia
archivo=<archivo.pdf>
```

### 5. Ver ganancias detalladas
```bash
GET /api/conductores/ganancias?periodo=mes
Authorization: Bearer {token}
```

### 6. Ver calificaciones
```bash
GET /api/conductores/calificaciones
Authorization: Bearer {token}
```

---

## 🆘 SOPORTE - Quick Start

### 1. Crear ticket
```bash
POST /api/soporte/tickets
Authorization: Bearer {token}
{
  "asunto": "Problema con pago",
  "descripcion": "Me cobraron de más",
  "categoria": "pago",
  "prioridad": "alta",
  "viaje_id": 1
}
```

### 2. Ver mis tickets
```bash
GET /api/soporte/tickets
Authorization: Bearer {token}
```

### 3. Ver detalles de ticket
```bash
GET /api/soporte/tickets/{ticket}
Authorization: Bearer {token}
```

### 4. Responder ticket
```bash
POST /api/soporte/tickets/{ticket}/responder
Authorization: Bearer {token}
{
  "mensaje": "Gracias por reportar"
}
```

### 5. Cambiar estado (Admin/Soporte)
```bash
PATCH /api/soporte/tickets/{ticket}/estado
Authorization: Bearer {token}
{
  "estado": "resuelto",
  "notas_cierre": "Se realizó reembolso"
}
```

### 6. Ver estadísticas (Admin/Soporte)
```bash
GET /api/soporte/estadisticas
Authorization: Bearer {token}
```

---

## 🔑 Usuarios de Prueba

| Rol | Email | Contraseña | Uso |
|-----|-------|-----------|-----|
| Admin | admin@carsigo.co | Admin@123 | Gestión general |
| Soporte | soporte@carsigo.co | Soporte@123 | Tickets |
| Conductor 1 | conductor1@carsigo.co | Conductor@123 | Test viajes |
| Conductor 2 | conductor2@carsigo.co | Conductor@123 | Test viajes |
| Pasajero 1 | pasajero1@carsigo.co | Pasajero@123 | Test solicitud |
| Pasajero 2 | pasajero2@carsigo.co | Pasajero@123 | Test solicitud |

---

## ✅ Estados Válidos

### Estados de Viaje
- `solicitado` - Pasajero solicitó, esperando conductor
- `asignado` - Conductor aceptó
- `en_progreso` - Viaje en curso
- `completado` - Viaje finalizado
- `cancelado` - Viaje cancelado

### Estados de Conexión (Conductor)
- `en_linea` - Disponible para viajes
- `fuera_linea` - No disponible
- `en_viaje` - En viaje actualmente

### Estados de Ticket
- `abierto` - Nuevo
- `en_espera` - Esperando info
- `en_progreso` - Siendo resuelto
- `resuelto` - Problema solucionado
- `cerrado` - Finalizado

### Categorías de Ticket
- `pago` - Problemas de pago
- `seguridad` - Problemas de seguridad
- `vehiculo` - Problemas del vehículo
- `conductor` - Comportamiento del conductor
- `pasajero` - Comportamiento del pasajero
- `aplicacion` - Bugs de la app
- `otro` - Otros

---

## 🔢 Métodos de Pago

```
efectivo
tarjeta_credito
tarjeta_debito
billetera_digital
transferencia_bancaria
nequi
daviplata
```

---

## 📋 Validaciones Importantes

### Coordenadas
- **Latitud:** -90 a +90
- **Longitud:** -180 a +180
- **Radio:** 0 a 100 km

### Calificación
- **Escala:** 1 a 5 estrellas
- **Requerida:** Después de completar viaje

### Documento
- **Tipos aceptados:** PDF, JPG, PNG
- **Tamaño máximo:** 5MB
- **Tipos:** licencia, cedula, seguro, inspeccion_tecnica

### Ticket
- **Asunto:** 1-255 caracteres
- **Descripción:** 10-2000 caracteres
- **Prioridad:** baja, media, alta, critica

---

## 🚨 Códigos de Error Comunes

| Código | Significado | Solución |
|--------|-------------|----------|
| 400 | Bad Request | Revisa parámetros |
| 401 | Unauthorized | Token inválido, login nuevamente |
| 403 | Forbidden | No tienes permisos |
| 404 | Not Found | Recurso no existe |
| 422 | Validation Error | Datos inválidos |
| 500 | Server Error | Error del servidor |

---

## 💡 Tips Útiles

### 1. Workflow Típico de Pasajero
```
1. POST /api/auth/login               → Obtener token
2. POST /api/viajes                   → Solicitar viaje
3. GET  /api/viajes/{id}              → Esperar conductor
4. POST /api/pagos/viajes/{id}/procesar → Pagar
5. POST /api/viajes/{id}/calificar    → Calificar
6. GET  /api/pagos/{id}/recibo        → Descargar recibo
```

### 2. Workflow Típico de Conductor
```
1. POST /api/auth/login                      → Obtener token
2. PATCH /api/conductores/mi-estado-conexion → Conectarse
3. POST  /api/ubicaciones/reportar           → Enviar ubicación
4. GET   /api/viajes/disponibles             → Ver viajes
5. PATCH /api/viajes/{id}/aceptar            → Aceptar viaje
6. PATCH /api/viajes/{id}/iniciar            → Iniciar
7. POST  /api/ubicaciones/reportar           → Reportar periódicamente
8. PATCH /api/viajes/{id}/completar          → Completar
9. GET   /api/pagos/resumen/ganancias        → Ver ganancias
```

### 3. Reportar Ubicación Continuamente
```javascript
// Cliente (Flutter/Web)
setInterval(() => {
  POST /api/ubicaciones/reportar
  {
    "latitud": currentLat,
    "longitud": currentLng,
    "precision": accuracyMeters
  }
}, 10000) // Cada 10 segundos
```

### 4. Pagination
```bash
GET /api/viajes?page=2&per_page=20
# Retorna 20 registros de la página 2
```

---

## 🔗 Relaciones de Datos

```
Usuario
  ├─ Viajes como Pasajero
  ├─ Viajes como Conductor (a través de Conductor)
  ├─ Pagos
  ├─ Tickets de Soporte
  └─ Comisiones (a través de Conductor)

Conductor
  ├─ Usuario
  ├─ Vehículos
  ├─ Viajes
  ├─ Ubicaciones
  ├─ Pagos
  └─ Comisiones

Viaje
  ├─ Pasajero (User)
  ├─ Conductor (User)
  ├─ Ubicaciones
  ├─ Pagos
  ├─ Emergencias
  └─ Tickets de Soporte

Pago
  ├─ Viaje
  ├─ Pasajero (User)
  ├─ Conductor (User)
  └─ Comisiones
```

---

## 📊 Estructura de Respuesta

### Respuesta Exitosa (200/201)
```json
{
  "success": true,
  "message": "Operación completada",
  "data": {
    "id": 1,
    "field": "value"
  }
}
```

### Respuesta de Error (40x/50x)
```json
{
  "success": false,
  "message": "Descripción del error",
  "errors": {
    "field": ["Mensaje de error"]
  }
}
```

### Respuesta Paginada
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [...],
    "total": 50,
    "per_page": 15,
    "last_page": 4
  }
}
```

---

## 🛠️ Debugging

### Verificar Token
```bash
curl -H "Authorization: Bearer {token}" \
     http://127.0.0.1:8000/api/auth/perfil
```

### Listar Rutas Registradas
```bash
php artisan route:list --path=api
```

### Ver Migraciones Ejecutadas
```bash
php artisan migrate:status
```

### Ejecutar Tests
```bash
bash test_api.sh
```

---

**Última actualización:** 26 de Diciembre de 2025  
**Versión:** 1.0  
**Endpoints:** 46+  
**Status:** ✅ Listo para Producción

