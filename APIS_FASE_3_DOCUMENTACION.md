# API REST - Fase 3: Documentación Completa

## 📋 Tabla de Contenidos

1. [Viajes](#viajes)
2. [Ubicaciones](#ubicaciones)
3. [Pagos](#pagos)
4. [Conductores](#conductores)
5. [Soporte](#soporte)
6. [Códigos de Error](#códigos-de-error)

---

## 🚗 Viajes

### 1. Listar Viajes
Obtiene el historial de viajes del usuario autenticado.

**Método:** `GET /api/viajes`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Parámetros Query:**
- `page` (opcional): Número de página (default: 1)
- `per_page` (opcional): Registros por página (default: 15)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "pasajero_id": 2,
        "conductor_id": 4,
        "origen_latitud": 10.4023,
        "origen_longitud": -75.5156,
        "destino_latitud": 10.4115,
        "destino_longitud": -75.5078,
        "origen_direccion": "Calle 1, El Carmen",
        "destino_direccion": "Calle 5, El Carmen",
        "estado": "completado",
        "tarifa_base": 5000,
        "distancia_estimada": 2.5,
        "duracion_estimada": 600,
        "precio_total": 10000,
        "hora_solicitud": "2025-12-26T10:30:00Z",
        "hora_asignacion": "2025-12-26T10:32:00Z",
        "hora_inicio": "2025-12-26T10:35:00Z",
        "hora_finalizacion": "2025-12-26T10:45:00Z",
        "calificacion_pasajero": 5,
        "calificacion_conductor": 5,
        "created_at": "2025-12-26T10:30:00Z",
        "updated_at": "2025-12-26T10:45:00Z"
      }
    ],
    "total": 15,
    "per_page": 15,
    "last_page": 1
  }
}
```

---

### 2. Crear Viaje
Permite a un pasajero solicitar un nuevo viaje.

**Método:** `POST /api/viajes`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "origen_latitud": 10.4023,
  "origen_longitud": -75.5156,
  "destino_latitud": 10.4115,
  "destino_longitud": -75.5078,
  "origen_direccion": "Calle 1, El Carmen",
  "destino_direccion": "Calle 5, El Carmen",
  "distancia_estimada": 2.5,
  "duracion_estimada": 600
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Viaje solicitado exitosamente",
  "data": {
    "id": 1,
    "pasajero_id": 2,
    "origen_latitud": 10.4023,
    "origen_longitud": -75.5156,
    "destino_latitud": 10.4115,
    "destino_longitud": -75.5078,
    "origen_direccion": "Calle 1, El Carmen",
    "destino_direccion": "Calle 5, El Carmen",
    "estado": "solicitado",
    "hora_solicitud": "2025-12-26T10:30:00Z",
    "created_at": "2025-12-26T10:30:00Z"
  }
}
```

**Errores Posibles:**
- `422`: Validación fallida (coordenadas inválidas)
- `403`: Usuario no es pasajero

---

### 3. Ver Viaje Específico
Obtiene detalles de un viaje específico.

**Método:** `GET /api/viajes/{viaje}`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "pasajero_id": 2,
    "conductor_id": 4,
    "estado": "en_progreso",
    "origen_direccion": "Calle 1, El Carmen",
    "destino_direccion": "Calle 5, El Carmen",
    "hora_solicitud": "2025-12-26T10:30:00Z",
    "hora_inicio": "2025-12-26T10:35:00Z"
  }
}
```

**Errores Posibles:**
- `404`: Viaje no encontrado
- `403`: No autorizado para ver este viaje

---

### 4. Listar Viajes Disponibles
Obtiene viajes sin asignar para que conductores los acepten.

**Método:** `GET /api/viajes/disponibles`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 5,
        "pasajero_id": 3,
        "origen_direccion": "Calle 2, El Carmen",
        "destino_direccion": "Carrera 3, El Carmen",
        "distancia_estimada": 1.8,
        "duracion_estimada": 480,
        "hora_solicitud": "2025-12-26T10:40:00Z"
      }
    ],
    "total": 5,
    "per_page": 10
  }
}
```

---

### 5. Conductor Acepta Viaje
Permite a un conductor aceptar un viaje solicitado.

**Método:** `PATCH /api/viajes/{viaje}/aceptar`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Viaje aceptado exitosamente",
  "data": {
    "id": 1,
    "conductor_id": 4,
    "estado": "asignado",
    "hora_asignacion": "2025-12-26T10:32:00Z"
  }
}
```

**Errores Posibles:**
- `400`: Viaje ya tiene conductor
- `403`: Solo conductores pueden aceptar viajes

---

### 6. Conductor Inicia Viaje
Marca el viaje como en progreso.

**Método:** `PATCH /api/viajes/{viaje}/iniciar`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Viaje iniciado exitosamente",
  "data": {
    "id": 1,
    "estado": "en_progreso",
    "hora_inicio": "2025-12-26T10:35:00Z"
  }
}
```

---

### 7. Conductor Completa Viaje
Finaliza el viaje con información de distancia y precio.

**Método:** `PATCH /api/viajes/{viaje}/completar`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "distancia_estimada": 2.5,
  "duracion_estimada": 600,
  "precio_total": 10000
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Viaje completado exitosamente",
  "data": {
    "id": 1,
    "estado": "completado",
    "hora_finalizacion": "2025-12-26T10:45:00Z",
    "precio_total": 10000
  }
}
```

---

### 8. Cancelar Viaje
Permite cancelar un viaje (pasajero o conductor).

**Método:** `PATCH /api/viajes/{viaje}/cancelar`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "razon_cancelacion": "Cambié de opinión"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Viaje cancelado exitosamente",
  "data": {
    "id": 1,
    "estado": "cancelado",
    "razon_cancelacion": "Cambié de opinión",
    "cancelado_por": "pasajero"
  }
}
```

---

### 9. Calificar Viaje
Permite al pasajero o conductor calificar el viaje.

**Método:** `POST /api/viajes/{viaje}/calificar`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "calificacion": 5,
  "comentario": "Excelente servicio"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Viaje calificado exitosamente",
  "data": {
    "id": 1,
    "calificacion_pasajero": 5,
    "comentario": "Excelente servicio",
    "conductor_calificacion_promedio": 4.8
  }
}
```

---

### 10. Obtener Ubicaciones del Viaje
Obtiene el historial de ubicaciones de un viaje.

**Método:** `GET /api/viajes/{viaje}/ubicaciones`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "viaje_id": 1,
      "conductor_id": 4,
      "latitud": 10.4023,
      "longitud": -75.5156,
      "timestamp_ubicacion": "2025-12-26T10:35:00Z"
    },
    {
      "id": 2,
      "viaje_id": 1,
      "conductor_id": 4,
      "latitud": 10.4050,
      "longitud": -75.5140,
      "timestamp_ubicacion": "2025-12-26T10:37:00Z"
    }
  ]
}
```

---

## 📍 Ubicaciones

### 1. Reportar Ubicación
Envía la ubicación actual del usuario (conductor o pasajero).

**Método:** `POST /api/ubicaciones/reportar`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "latitud": 10.4023,
  "longitud": -75.5156,
  "precision": 5.0,
  "proveedor": "gps"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Ubicación reportada exitosamente",
  "data": {
    "id": 1,
    "conductor_id": 4,
    "viaje_id": 1,
    "latitud": 10.4023,
    "longitud": -75.5156,
    "timestamp_ubicacion": "2025-12-26T10:35:15Z"
  }
}
```

---

### 2. Obtener Ubicaciones Recientes del Conductor
Obtiene las últimas ubicaciones reportadas por un conductor.

**Método:** `GET /api/ubicaciones/conductor/recientes`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 10,
      "latitud": 10.4100,
      "longitud": -75.5100,
      "timestamp_ubicacion": "2025-12-26T10:40:00Z"
    },
    {
      "id": 9,
      "latitud": 10.4090,
      "longitud": -75.5090,
      "timestamp_ubicacion": "2025-12-26T10:38:00Z"
    }
  ]
}
```

---

### 3. Encontrar Conductores Cercanos
Busca conductores dentro de un radio especificado.

**Método:** `GET /api/ubicaciones/conductores/cercanos`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Parámetros Query:**
- `latitud` (requerido): Latitud de referencia
- `longitud` (requerido): Longitud de referencia
- `radio` (opcional): Radio en km (default: 5)

**Ejemplo:** `/api/ubicaciones/conductores/cercanos?latitud=10.4023&longitud=-75.5156&radio=2`

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 4,
      "usuario_id": 4,
      "latitud": 10.4040,
      "longitud": -75.5140,
      "distancia_km": 0.35,
      "calificacion_promedio": 4.8,
      "estado": "activo",
      "estado_conexion": "en_linea"
    },
    {
      "id": 5,
      "usuario_id": 5,
      "latitud": 10.4100,
      "longitud": -75.5100,
      "distancia_km": 1.2,
      "calificacion_promedio": 4.5,
      "estado": "activo",
      "estado_conexion": "en_linea"
    }
  ]
}
```

---

### 4. Histórico de Ubicaciones de Viaje
Obtiene todas las ubicaciones registradas durante un viaje.

**Método:** `GET /api/ubicaciones/viajes/{viaje}/historico`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "latitud": 10.4023,
      "longitud": -75.5156,
      "timestamp_ubicacion": "2025-12-26T10:35:00Z"
    },
    {
      "id": 2,
      "latitud": 10.4050,
      "longitud": -75.5140,
      "timestamp_ubicacion": "2025-12-26T10:37:00Z"
    }
  ]
}
```

---

### 5. Limpiar Ubicaciones Antiguas
Elimina ubicaciones con más de 30 días de antigüedad (mantenimiento).

**Método:** `DELETE /api/ubicaciones/limpiar`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "45 ubicaciones antiguas eliminadas"
}
```

---

## 💰 Pagos

### 1. Listar Pagos
Obtiene el historial de pagos del usuario.

**Método:** `GET /api/pagos`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "viaje_id": 1,
        "numero_transaccion": "TRX-12345678",
        "monto_subtotal": 10000,
        "impuesto": 800,
        "descuento": 0,
        "monto_total": 10800,
        "comision_plataforma": 540,
        "monto_conductor": 10260,
        "metodo_pago": "tarjeta_credito",
        "estado": "completado",
        "fecha_solicitud": "2025-12-26T10:45:00Z",
        "fecha_completacion": "2025-12-26T10:46:00Z"
      }
    ],
    "total": 15,
    "per_page": 15
  }
}
```

---

### 2. Ver Detalles de Pago
Obtiene información detallada de un pago específico.

**Método:** `GET /api/pagos/{pago}`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "viaje_id": 1,
    "numero_transaccion": "TRX-12345678",
    "monto_subtotal": 10000,
    "monto_total": 10800,
    "metodo_pago": "tarjeta_credito",
    "estado": "completado",
    "viaje": {
      "id": 1,
      "origen_direccion": "Calle 1, El Carmen",
      "destino_direccion": "Calle 5, El Carmen"
    }
  }
}
```

---

### 3. Procesar Pago de Viaje
Procesa el pago después de completar un viaje.

**Método:** `POST /api/pagos/viajes/{viaje}/procesar`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "metodo_pago": "tarjeta_credito",
  "requiere_factura": true
}
```

**Métodos de Pago Aceptados:**
- `efectivo`
- `tarjeta_credito`
- `tarjeta_debito`
- `billetera_digital`
- `transferencia_bancaria`
- `nequi`
- `daviplata`

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Pago procesado exitosamente",
  "data": {
    "id": 1,
    "viaje_id": 1,
    "numero_transaccion": "TRX-12345678",
    "monto_total": 10800,
    "monto_conductor": 10260,
    "estado": "completado",
    "fecha_completacion": "2025-12-26T10:46:00Z"
  }
}
```

---

### 4. Reembolsar Pago
Reembolsa un pago completado (solo admin).

**Método:** `POST /api/pagos/{pago}/reembolsar`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "razon": "Error en el viaje"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Pago reembolsado exitosamente",
  "data": {
    "id": 1,
    "estado": "reembolsado",
    "fecha_completacion": "2025-12-26T10:50:00Z"
  }
}
```

---

### 5. Resumen de Ganancias
Obtiene un resumen de ganancias para el conductor autenticado.

**Método:** `GET /api/pagos/resumen/ganancias`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "ganancias_totales": 250000,
    "saldo_pendiente": 50000,
    "total_viajes": 45,
    "calificacion_promedio": 4.8,
    "ganancias_hoy": 25000,
    "ganancias_mes": 180000
  }
}
```

---

### 6. Obtener Recibo de Pago
Descarga el recibo/comprobante de un pago.

**Método:** `GET /api/pagos/{pago}/recibo`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "numero_transaccion": "TRX-12345678",
    "fecha": "2025-12-26T10:46:00Z",
    "origen": "Calle 1, El Carmen",
    "destino": "Calle 5, El Carmen",
    "distancia": "2.5 km",
    "duracion": "10 minutos",
    "desglose": {
      "subtotal": 10000,
      "impuesto": 800,
      "descuento": 0,
      "total": 10800
    },
    "metodo_pago": "tarjeta_credito",
    "estado": "completado"
  }
}
```

---

## 🚗 Conductores

### 1. Listar Conductores
Obtiene lista de conductores (admin/soporte).

**Método:** `GET /api/conductores`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Parámetros Query:**
- `estado` (opcional): Filtrar por estado (activo, inactivo, suspendido)
- `buscar` (opcional): Buscar por nombre o email

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "usuario_id": 4,
        "numero_licencia": "L-1234567890",
        "tipo_licencia": "C",
        "calificacion_promedio": 4.8,
        "ganancias_totales": 250000,
        "total_viajes": 45,
        "estado": "activo",
        "usuario": {
          "id": 4,
          "nombre": "Juan Pérez",
          "email": "conductor1@carsigo.co",
          "telefono": "3001234567"
        }
      }
    ],
    "total": 5,
    "per_page": 15
  }
}
```

---

### 2. Mi Perfil de Conductor
Obtiene el perfil del conductor autenticado.

**Método:** `GET /api/conductores/mi-perfil`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "numero_licencia": "L-1234567890",
    "tipo_licencia": "C",
    "fecha_vencimiento_licencia": "2027-12-31",
    "calificacion_promedio": 4.8,
    "ganancias_totales": 250000,
    "saldo_pendiente": 50000,
    "total_viajes": 45,
    "estado": "activo",
    "estado_conexion": "en_linea",
    "usuario": {
      "id": 4,
      "nombre": "Juan Pérez",
      "email": "conductor1@carsigo.co",
      "telefono": "3001234567",
      "cédula": "1234567890",
      "fecha_nacimiento": "1990-01-15"
    },
    "vehiculos": [
      {
        "id": 1,
        "placa": "ABC123",
        "marca": "Toyota",
        "modelo": "Corolla",
        "anio": 2020
      }
    ]
  }
}
```

---

### 3. Ver Perfil de Conductor
Obtiene el perfil público de cualquier conductor.

**Método:** `GET /api/conductores/{conductor}`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "calificacion_promedio": 4.8,
    "total_viajes": 45,
    "usuario": {
      "id": 4,
      "nombre": "Juan Pérez",
      "foto_perfil": "https://...",
      "ubicacion_ciudad": "El Carmen de Bolívar"
    }
  }
}
```

---

### 4. Actualizar Perfil de Conductor
Actualiza información del perfil del conductor.

**Método:** `PUT /api/conductores/mi-perfil`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "numero_licencia": "L-9876543210",
  "fecha_vencimiento_licencia": "2028-06-30",
  "tipo_licencia": "C",
  "banco": "Bancolombia",
  "numero_cuenta": "45061234567890",
  "tipo_cuenta": "ahorros"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Perfil actualizado exitosamente",
  "data": {
    "id": 1,
    "numero_licencia": "L-9876543210",
    "banco": "Bancolombia"
  }
}
```

---

### 5. Cambiar Estado de Conexión
Cambiar si el conductor está en línea, fuera de línea o en viaje.

**Método:** `PATCH /api/conductores/mi-estado-conexion`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "estado_conexion": "en_linea"
}
```

**Estados Válidos:**
- `en_linea`
- `fuera_linea`
- `en_viaje`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Estado de conexión actualizado",
  "data": {
    "estado_conexion": "en_linea",
    "ultima_conexion": "2025-12-26T10:50:00Z"
  }
}
```

---

### 6. Ver Documentos
Obtiene el estado de los documentos requeridos del conductor.

**Método:** `GET /api/conductores/documentos`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "licencia": {
      "numero": "L-1234567890",
      "tipo": "C",
      "vencimiento": "2027-12-31",
      "estado": "vigente"
    },
    "antecedentes": {
      "verificado": true,
      "fecha_verificacion": "2025-01-15"
    },
    "seguro_vehiculo": {
      "activo": true
    }
  }
}
```

---

### 7. Subir Documento
Carga un documento requerido (licencia, cédula, etc).

**Método:** `POST /api/conductores/documentos/subir`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Parámetros:**
- `tipo_documento` (requerido): `licencia`, `cedula`, `seguro`, `inspeccion_tecnica`
- `archivo` (requerido): Archivo PDF, JPG, PNG (máx 5MB)

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Documento cargado exitosamente",
  "data": {
    "tipo": "licencia",
    "archivo": "licencia-1703591400.pdf",
    "fecha_carga": "2025-12-26T10:50:00Z"
  }
}
```

---

### 8. Obtener Ganancias
Obtiene detalles de ganancias por período.

**Método:** `GET /api/conductores/ganancias`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Parámetros Query:**
- `periodo` (opcional): `semana`, `mes`, `año` (default: mes)
- `conductor_id` (opcional): Para admin consultar otros conductores

**Ejemplo:** `/api/conductores/ganancias?periodo=mes`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "periodo": "mes",
    "total_viajes": 45,
    "ganancias_brutas": 450000,
    "comisiones_plataforma": 22500,
    "ganancias_netas": 427500,
    "promedio_por_viaje": 9500,
    "viajes": [
      {
        "id": 1,
        "viaje_id": 1,
        "fecha": "2025-12-26T10:46:00Z",
        "monto_total": 10800,
        "comision": 540,
        "monto_neto": 10260
      }
    ]
  }
}
```

---

### 9. Ver Calificaciones
Obtiene el historial de calificaciones del conductor.

**Método:** `GET /api/conductores/calificaciones`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "estadisticas": {
      "promedio_general": 4.8,
      "total_calificaciones": 45,
      "distribucion": {
        "5_estrellas": 40,
        "4_estrellas": 4,
        "3_estrellas": 1,
        "2_estrellas": 0,
        "1_estrella": 0
      }
    },
    "calificaciones": {
      "current_page": 1,
      "data": [
        {
          "id": 1,
          "calificacion_conductor": 5,
          "hora_finalizacion": "2025-12-26T10:45:00Z",
          "pasajero": {
            "id": 2,
            "nombre": "María García",
            "foto_perfil": "https://..."
          }
        }
      ],
      "total": 45,
      "per_page": 20
    }
  }
}
```

---

### 10. Cambiar Estado de Conductor (Admin)
Cambia el estado de un conductor (activo, inactivo, suspendido).

**Método:** `PATCH /api/conductores/{conductor}/estado`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "estado": "suspendido",
  "razon": "Incumplimiento de normas"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Estado actualizado exitosamente",
  "data": {
    "id": 1,
    "estado": "suspendido"
  }
}
```

---

## 🆘 Soporte

### 1. Listar Tickets de Soporte
Obtiene el historial de tickets de soporte.

**Método:** `GET /api/soporte/tickets`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Parámetros Query:**
- `estado` (opcional): `abierto`, `en_espera`, `en_progreso`, `resuelto`, `cerrado`
- `prioridad` (opcional): `baja`, `media`, `alta`, `critica`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "numero_ticket": "TKT-12345678",
        "usuario_id": 2,
        "asunto": "Cobro indebido",
        "descripcion": "Me cobraron $15.000 pero la tarifa debe ser $10.000",
        "categoria": "pago",
        "prioridad": "alta",
        "estado": "en_progreso",
        "created_at": "2025-12-26T10:30:00Z",
        "updated_at": "2025-12-26T10:40:00Z"
      }
    ],
    "total": 5,
    "per_page": 15
  }
}
```

---

### 2. Crear Ticket de Soporte
Crea un nuevo ticket de soporte.

**Método:** `POST /api/soporte/tickets`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "asunto": "Problema con conductor",
  "descripcion": "El conductor se negó a llevarme al destino",
  "categoria": "seguridad",
  "prioridad": "critica",
  "viaje_id": 1
}
```

**Categorías Válidas:**
- `pago`
- `seguridad`
- `vehiculo`
- `conductor`
- `pasajero`
- `aplicacion`
- `otro`

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Ticket creado exitosamente",
  "data": {
    "id": 1,
    "numero_ticket": "TKT-ABCD1234",
    "asunto": "Problema con conductor",
    "estado": "abierto",
    "prioridad": "critica",
    "created_at": "2025-12-26T10:30:00Z"
  }
}
```

---

### 3. Ver Detalles de Ticket
Obtiene información completa de un ticket incluyendo respuestas.

**Método:** `GET /api/soporte/tickets/{ticket}`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "numero_ticket": "TKT-ABCD1234",
    "usuario_id": 2,
    "asunto": "Problema con conductor",
    "descripcion": "El conductor se negó a llevarme al destino",
    "categoria": "seguridad",
    "prioridad": "critica",
    "estado": "en_progreso",
    "usuario": {
      "id": 2,
      "nombre": "María García",
      "email": "pasajero1@carsigo.co"
    },
    "respuestas": [
      {
        "id": 1,
        "usuario_id": 3,
        "mensaje": "Hemos revisado el viaje. Se reportó al conductor.",
        "es_respuesta_staff": true,
        "created_at": "2025-12-26T10:35:00Z"
      }
    ]
  }
}
```

---

### 4. Responder a Ticket
Agrega una respuesta/comentario a un ticket.

**Método:** `POST /api/soporte/tickets/{ticket}/responder`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "mensaje": "Gracias por reportar. Hemos tomado acciones correctivas."
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Respuesta agregada exitosamente",
  "data": {
    "respuesta_id": 1,
    "mensaje": "Gracias por reportar. Hemos tomado acciones correctivas.",
    "fecha": "2025-12-26T10:35:00Z",
    "usuario_tipo": "staff"
  }
}
```

---

### 5. Cambiar Estado de Ticket
Actualiza el estado de un ticket (solo staff/admin).

**Método:** `PATCH /api/soporte/tickets/{ticket}/estado`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "estado": "resuelto",
  "notas_cierre": "Se realizó reembolso de $10.000"
}
```

**Estados Válidos:**
- `abierto`
- `en_espera`
- `en_progreso`
- `resuelto`
- `cerrado`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Estado actualizado exitosamente",
  "data": {
    "id": 1,
    "numero_ticket": "TKT-ABCD1234",
    "estado": "resuelto"
  }
}
```

---

### 6. Asignar Ticket a Agente
Asigna un ticket a un agente de soporte (solo admin).

**Método:** `PATCH /api/soporte/tickets/{ticket}/asignar`

**Headers Requeridos:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "agente_id": 3
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Ticket asignado exitosamente",
  "data": {
    "id": 1,
    "numero_ticket": "TKT-ABCD1234",
    "asignado_a": 3,
    "estado": "en_progreso"
  }
}
```

---

### 7. Estadísticas de Soporte
Obtiene estadísticas generales de tickets (solo admin/soporte).

**Método:** `GET /api/soporte/estadisticas`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "total_tickets": 125,
    "tickets_abiertos": 15,
    "tickets_en_progreso": 8,
    "tickets_resueltos": 92,
    "tickets_cerrados": 10,
    "por_prioridad": {
      "critica": 3,
      "alta": 8,
      "media": 25,
      "baja": 89
    },
    "por_categoria": {
      "pago": 35,
      "seguridad": 15,
      "vehiculo": 20,
      "conductor": 25,
      "pasajero": 15,
      "aplicacion": 10,
      "otro": 5
    },
    "tiempo_promedio_resolucion": "24.5 horas"
  }
}
```

---

## ❌ Códigos de Error

### Errores de Autenticación (40x)

| Código | Mensaje | Solución |
|--------|---------|----------|
| 401 | Unauthorized | Token inválido o expirado. Realiza login nuevamente |
| 403 | Forbidden | No tienes permisos para esta acción |
| 422 | Validation Failed | Validación fallida. Revisa los parámetros |

### Errores del Servidor (50x)

| Código | Mensaje | Solución |
|--------|---------|----------|
| 500 | Internal Server Error | Error en el servidor. Reintenta después |
| 503 | Service Unavailable | Servidor en mantenimiento |

---

## 📝 Ejemplo: Flujo Completo de un Viaje

### 1. Pasajero solicita viaje
```bash
POST /api/viajes
{
  "origen_latitud": 10.4023,
  "origen_longitud": -75.5156,
  "destino_latitud": 10.4115,
  "destino_longitud": -75.5078,
  "origen_direccion": "Calle 1, El Carmen",
  "destino_direccion": "Calle 5, El Carmen",
  "distancia_estimada": 2.5,
  "duracion_estimada": 600
}
```

### 2. Conductor obtiene viajes disponibles
```bash
GET /api/viajes/disponibles
```

### 3. Conductor busca viajes cercanos
```bash
GET /api/ubicaciones/conductores/cercanos?latitud=10.4023&longitud=-75.5156&radio=2
```

### 4. Conductor reporta ubicación
```bash
POST /api/ubicaciones/reportar
{
  "latitud": 10.4023,
  "longitud": -75.5156,
  "precision": 5.0,
  "proveedor": "gps"
}
```

### 5. Conductor acepta viaje
```bash
PATCH /api/viajes/1/aceptar
```

### 6. Conductor inicia viaje
```bash
PATCH /api/viajes/1/iniciar
```

### 7. Conductor reporta ubicación continuamente
```bash
POST /api/ubicaciones/reportar
(cada 10-30 segundos)
```

### 8. Conductor completa viaje
```bash
PATCH /api/viajes/1/completar
{
  "distancia_estimada": 2.5,
  "duracion_estimada": 600,
  "precio_total": 10000
}
```

### 9. Procesar pago
```bash
POST /api/pagos/viajes/1/procesar
{
  "metodo_pago": "tarjeta_credito",
  "requiere_factura": true
}
```

### 10. Ambos califican viaje
```bash
POST /api/viajes/1/calificar
{
  "calificacion": 5,
  "comentario": "Excelente servicio"
}
```

### 11. Pasajero descarga recibo
```bash
GET /api/pagos/1/recibo
```

---

## 🎯 Notas Importantes

1. **Autenticación:** Todos los endpoints (excepto registro y login) requieren `Authorization: Bearer {token}`
2. **Roles:** Los endpoints respetan roles (pasajero, conductor, soporte, admin)
3. **Ubicaciones en Tiempo Real:** Los conductores deben reportar ubicaciones cada 10-30 segundos
4. **Validaciones:** Las coordenadas deben estar en el rango: latitud [-90, 90], longitud [-180, 180]
5. **Estados de Viaje:** solicitado → asignado → en_progreso → completado/cancelado
6. **Métodos HTTP:** POST (crear), GET (leer), PATCH (actualizar parcial), DELETE (eliminar)
7. **Rate Limiting:** Máximo 100 requests/minuto por token

---

**Última actualización:** 26 de Diciembre de 2025
**Versión API:** 1.0
**Estado:** ✅ Fase 3 Completada
