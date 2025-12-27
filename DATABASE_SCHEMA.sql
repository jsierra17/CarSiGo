-- ========================================
-- DOCUMENTACIÓN DE BASE DE DATOS - CarSiGo
-- ========================================
-- Base de datos: carsigo
-- Motor: PostgreSQL 13+
-- Fecha: Diciembre 2025
-- Estado: Creada y configurada

-- ========================================
-- DIAGRAMA DE RELACIONES
-- ========================================

/*
┌──────────────────┐
│     users        │
├──────────────────┤
│ id (PK)          │
│ name             │
│ email (UNIQUE)   │
│ password         │
│ tipo_usuario     │ ─────┐
│ estado_cuenta    │      │
│ ... (más campos) │      │
└──────────────────┘      │
        │                 │
        │ 1:1             │
        │                 │
    ┌───┴─────────────────┴──────────┬─────────────────────────┐
    │                                │                         │
    v                                v                         v
┌──────────────────┐        ┌─────────────────┐      ┌──────────────────┐
│  conductores     │        │ viajes          │      │  emergencias     │
├──────────────────┤        ├─────────────────┤      ├──────────────────┤
│ id (PK)          │        │ id (PK)         │      │ id (PK)          │
│ usuario_id (FK)  │        │ pasajero_id(FK) │      │ usuario_id (FK)  │
│ numero_licencia  │        │ conductor_id(FK)│      │ viaje_id (FK)    │
│ estado           │        │ origen_*        │      │ tipo             │
│ calificacion_*   │        │ destino_*       │      │ estado           │
│ ...              │        │ estado          │      │ prioridad        │
└──────────────────┘        │ ...             │      │ ...              │
        │                   └─────────────────┘      └──────────────────┘
        │ 1:N                      │
        │                          │ 1:1
        v                          v
┌──────────────────┐        ┌─────────────────┐
│  vehiculos       │        │  pagos          │
├──────────────────┤        ├─────────────────┤
│ id (PK)          │        │ id (PK)         │
│ conductor_id(FK) │        │ viaje_id (FK)   │
│ placa (UNIQUE)   │        │ pasajero_id(FK) │
│ marca/modelo     │        │ conductor_id(FK)│
│ categoria        │        │ monto_*         │
│ estado           │        │ estado          │
│ ...              │        │ metodo_pago     │
└──────────────────┘        └─────────────────┘
                                    │
                                    │ 1:N
                                    v
                            ┌─────────────────┐
                            │  comisiones     │
                            ├─────────────────┤
                            │ id (PK)         │
                            │ conductor_id(FK)│
                            │ pago_id (FK)    │
                            │ monto_*         │
                            │ estado          │
                            │ ...             │
                            └─────────────────┘

┌─────────────────┐        ┌──────────────────┐
│  ubicaciones    │        │  soporte_tickets │
├─────────────────┤        ├──────────────────┤
│ id (PK)         │        │ id (PK)          │
│ conductor_id(FK)│        │ usuario_id (FK)  │
│ pasajero_id(FK) │        │ viaje_id (FK)    │
│ viaje_id (FK)   │        │ numero_ticket    │
│ latitud         │        │ asunto           │
│ longitud        │        │ estado           │
│ timestamp_*     │        │ ...              │
│ ...             │        └──────────────────┘
└─────────────────┘

┌─────────────────┐        ┌──────────────────┐
│  promociones    │        │  logs_sistema    │
├─────────────────┤        ├──────────────────┤
│ id (PK)         │        │ id (PK)          │
│ codigo (UNIQUE) │        │ usuario_id (FK)  │
│ nombre          │        │ tipo_evento      │
│ tipo            │        │ descripcion      │
│ valor           │        │ ip_address       │
│ activa          │        │ ...              │
│ ...             │        └──────────────────┘
└─────────────────┘

┌──────────────────┐
│  configuracion   │
├──────────────────┤
│ id (PK)          │
│ clave (UNIQUE)   │
│ valor            │
│ categoria        │
│ ...              │
└──────────────────┘
*/

-- ========================================
-- DESCRIPCIONES DE TABLAS
-- ========================================

-- Tabla: users
-- Descripción: Usuarios de la plataforma (pasajeros, conductores, admins, soporte)
-- Campos clave:
--   - tipo_usuario: pasajero, conductor, admin, soporte
--   - estado_cuenta: activa, inactiva, suspendida, verificacion
--   - email_verificado: Boolean para confirmación de email
--   - telefono_verificado: Boolean para confirmación de teléfono

-- Tabla: conductores
-- Descripción: Información detallada de conductores y su desempeño
-- Campos clave:
--   - numero_licencia: Identificador único de licencia
--   - estado: activo, inactivo, suspendido, verificacion
--   - calificacion_promedio: Promedio de calificaciones (1-5)
--   - total_viajes: Contador de viajes completados
--   - estado_conexion: en_linea, fuera_linea, en_viaje
--   - comision_porcentaje: Porcentaje que retiene la plataforma

-- Tabla: vehiculos
-- Descripción: Información de vehículos registrados por conductores
-- Campos clave:
--   - placa: Identificador único del vehículo
--   - categoria: basico, confort, premium, compartido
--   - capacidad_pasajeros: Número de pasajeros permitidos
--   - documentos_vigentes: Boolean para validación de documentos
--   - tiene_gps, tiene_boton_panico, tiene_camara: Características de seguridad

-- Tabla: viajes
-- Descripción: Registro de todos los viajes realizados en la plataforma
-- Campos clave:
--   - pasajero_id: Usuario que solicitó el viaje
--   - conductor_id: Conductor asignado (puede ser NULL)
--   - origen_latitud/longitud: Coordenadas de origen
--   - destino_latitud/longitud: Coordenadas de destino
--   - estado: solicitado, asignado, en_progreso, completado, cancelado
--   - calificacion_pasajero/conductor: Ratings mutuos (1-5)

-- Tabla: ubicaciones
-- Descripción: Registro en tiempo real de ubicaciones de usuarios durante viajes
-- Campos clave:
--   - tipo: conductor, pasajero_en_viaje, ubicacion_interes
--   - latitud/longitud: Coordenadas GPS
--   - timestamp_ubicacion: Hora exacta de registro
--   - velocidad, rumbo: Información de movimiento

-- Tabla: pagos
-- Descripción: Registro de todas las transacciones monetarias
-- Campos clave:
--   - viaje_id: Viaje asociado al pago
--   - metodo_pago: efectivo, tarjeta_credito, billetera_digital, etc
--   - estado: pendiente, procesando, completado, fallido, reembolsado
--   - monto_conductor: Dinero que recibe el conductor
--   - comision_plataforma: Comisión retenida

-- Tabla: comisiones
-- Descripción: Detalles de comisiones pagadas a conductores
-- Campos clave:
--   - porcentaje_comision: Porcentaje aplicado
--   - estado: pendiente, retenida, pagada, disputada
--   - deducciones: daños, multas, etc

-- Tabla: promociones
-- Descripción: Códigos de descuento y promociones
-- Campos clave:
--   - codigo: Código único de promoción
--   - tipo: descuento_porcentaje, descuento_fijo, viaje_gratis, credito_bienvenida
--   - valor: Valor del descuento o crédito
--   - aplica_a: todos, nuevos_usuarios, usuarios_existentes, conductores
--   - activa: Boolean para activar/desactivar

-- Tabla: emergencias
-- Descripción: Registro de situaciones de emergencia reportadas
-- Campos clave:
--   - tipo: accidente, asalto, acoso, problema_medico, etc
--   - prioridad: baja, media, alta, critica
--   - estado: activa, respondida, resuelta, cancelada
--   - requiere_policia/ambulancia: Booleanos para respuesta

-- Tabla: soporte_tickets
-- Descripción: Tickets de soporte técnico y atención al usuario
-- Campos clave:
--   - numero_ticket: Identificador único
--   - categoria: viaje, pago, conductor, pasajero, vehiculo, app
--   - estado: abierto, en_progreso, esperando_usuario, resuelto, cerrado
--   - respondido_por_llm: Boolean si fue automatizado
--   - respuesta_automatica: Respuesta generada por IA

-- Tabla: logs_sistema
-- Descripción: Auditoría completa de eventos del sistema
-- Campos clave:
--   - tipo_evento: Tipo de evento (inicio_sesion, cambio_configuracion, etc)
--   - usuario_id: Usuario involucrado
--   - entidad/id_entidad: Qué se modificó
--   - estado: exitoso, fallo, advertencia, info
--   - ip_address, user_agent: Información técnica

-- Tabla: configuracion
-- Descripción: Configuraciones dinámicas del sistema
-- Campos clave:
--   - clave: Identificador único (ej: tarifa_base)
--   - valor: Valor actual
--   - categoria: general, precios, comisiones, seguridad, etc
--   - editable: Boolean para permitir cambios en runtime

-- ========================================
-- ÍNDICES PRINCIPALES
-- ========================================

-- Búsquedas por usuario
-- users.email, users.id, users.tipo_usuario
-- conductores.usuario_id, conductores.estado
-- viajes.pasajero_id, viajes.conductor_id

-- Búsquedas geográficas
-- ubicaciones.latitud, ubicaciones.longitud
-- ubicaciones.conductor_id, ubicaciones.viaje_id
-- viajes.origen_latitud, viajes.origen_longitud

-- Búsquedas por estado
-- viajes.estado, viajes.hora_solicitud
-- pagos.estado, pagos.fecha_solicitud
-- emergencias.estado, emergencias.prioridad

-- Búsquedas por tiempo
-- logs_sistema.created_at, logs_sistema.usuario_id
-- ubicaciones.timestamp_ubicacion

-- ========================================
-- RESTRICCIONES Y VALIDACIONES
-- ========================================

-- Foreign Keys:
--   - conductores.usuario_id -> users.id (ON DELETE CASCADE)
--   - vehiculos.conductor_id -> conductores.id (ON DELETE CASCADE)
--   - viajes.pasajero_id -> users.id (ON DELETE CASCADE)
--   - viajes.conductor_id -> conductores.id (ON DELETE SET NULL)
--   - pagos.viaje_id -> viajes.id (ON DELETE CASCADE)
--   - comisiones.conductor_id -> conductores.id (ON DELETE CASCADE)
--   - emergencias.usuario_id -> users.id (ON DELETE CASCADE)
--   - soporte_tickets.usuario_id -> users.id (ON DELETE CASCADE)

-- Unique Constraints:
--   - users.email
--   - conductores.numero_licencia
--   - vehiculos.placa, numero_chasis, numero_motor, numero_soat, numero_permisoOperativo
--   - pagos.numero_transaccion
--   - soporte_tickets.numero_ticket
--   - promociones.codigo
--   - usuarios.telefono, numero_documento

-- Check Constraints (implícitos en enums):
--   - users.tipo_usuario IN ('pasajero', 'conductor', 'admin', 'soporte')
--   - users.estado_cuenta IN ('activa', 'inactiva', 'suspendida', 'verificacion')
--   - viajes.estado IN ('solicitado', 'asignado', 'conductor_en_ruta', 'en_progreso', 'completado', 'cancelado', 'no_presentado')

-- ========================================
-- CONSULTAS ÚTILES
-- ========================================

-- Obtener conductores activos con sus vehículos
SELECT c.id, u.name, c.calificacion_promedio, c.estado_conexion, v.marca, v.modelo, v.placa
FROM conductores c
JOIN users u ON c.usuario_id = u.id
LEFT JOIN vehiculos v ON c.id = v.conductor_id
WHERE c.estado = 'activo' AND c.estado_conexion = 'en_linea';

-- Obtener viajes completados en los últimos 7 días
SELECT v.id, u.name as pasajero, c.usuario_id, v.precio_total, v.hora_finalizacion
FROM viajes v
JOIN users u ON v.pasajero_id = u.id
LEFT JOIN conductores c ON v.conductor_id = c.id
WHERE v.estado = 'completado'
  AND v.hora_finalizacion >= NOW() - INTERVAL '7 days'
ORDER BY v.hora_finalizacion DESC;

-- Calcular ganancias por conductor
SELECT c.id, u.name, 
       SUM(p.monto_conductor) as ganancias_totales,
       COUNT(v.id) as total_viajes,
       AVG(v.calificacion_conductor) as calificacion_promedio
FROM conductores c
JOIN users u ON c.usuario_id = u.id
LEFT JOIN viajes v ON c.id = v.conductor_id
LEFT JOIN pagos p ON v.id = p.viaje_id
WHERE p.estado = 'completado'
GROUP BY c.id, u.name
ORDER BY ganancias_totales DESC;

-- Monitoreo de emergencias activas
SELECT e.id, e.numero_reporte_policia, u.name, e.tipo, e.prioridad, e.estado
FROM emergencias e
JOIN users u ON e.usuario_id = u.id
WHERE e.estado IN ('activa', 'respondida')
ORDER BY e.prioridad DESC, e.created_at DESC;

-- Tickets de soporte pendientes
SELECT st.numero_ticket, u.name, st.asunto, st.prioridad, st.estado
FROM soporte_tickets st
JOIN users u ON st.usuario_id = u.id
WHERE st.estado IN ('abierto', 'en_progreso', 'esperando_usuario')
ORDER BY st.prioridad DESC, st.created_at ASC;

-- ========================================
-- NOTAS IMPORTANTES
-- ========================================

-- 1. GEOLOCALIZACIÓN
--    - Usar PostGIS para búsquedas geográficas más eficientes
--    - Crear índice GIST: CREATE INDEX idx_ubicaciones_geo ON ubicaciones USING GIST(ll_to_earth(latitud, longitud))

-- 2. PERFORMANCE
--    - Los índices están optimizados para las búsquedas más frecuentes
--    - Usar EXPLAIN ANALYZE para optimizar queries lentas
--    - Considerar particionamiento de tablas grandes (viajes, ubicaciones, logs_sistema)

-- 3. AUDITORÍA
--    - logs_sistema debe crecer constantemente; considerar rotación de datos
--    - Implementar triggers para registros de cambios automáticos

-- 4. SEGURIDAD
--    - Nunca almacenar tokens directamente; usar hashes
--    - Encriptar datos sensibles (licencias, documentos)
--    - Implementar rate limiting a nivel de aplicación

-- 5. BACKUPS
--    - Realizar backups diarios
--    - Probar restauración regularmente
--    - Considerar replicación para alta disponibilidad

-- ========================================
-- MIGRATIONS EJECUTADAS
-- ========================================
-- ✅ 2025_12_26_100000_create_conductores_table
-- ✅ 2025_12_26_100001_create_vehiculos_table
-- ✅ 2025_12_26_100002_create_viajes_table
-- ✅ 2025_12_26_100003_create_ubicaciones_table
-- ✅ 2025_12_26_100004_create_pagos_table
-- ✅ 2025_12_26_100005_create_comisiones_table
-- ✅ 2025_12_26_100006_create_promociones_table
-- ✅ 2025_12_26_100007_create_emergencias_table
-- ✅ 2025_12_26_100008_create_soporte_tickets_table
-- ✅ 2025_12_26_100009_create_logs_sistema_table
-- ✅ 2025_12_26_100010_create_configuracion_table
-- ✅ 2025_12_26_100011_add_extended_fields_to_users_table

-- ========================================
-- FIN DE DOCUMENTACIÓN
-- ========================================
