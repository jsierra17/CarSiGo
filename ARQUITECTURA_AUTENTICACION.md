# 🏗️ ARQUITECTURA DE AUTENTICACIÓN - CarSiGo

## Diagrama de Flujo de Autenticación

```
┌─────────────────────────────────────────────────────────────────┐
│                     CLIENTE (Flutter App)                       │
│                                                                 │
│  ┌────────────────┐  ┌──────────────┐  ┌─────────────────────┐│
│  │ Login Screen   │  │ Home Screen  │  │ Profile Management  ││
│  └────────────────┘  └──────────────┘  └─────────────────────┘│
└─────────────────┬──────────────────────────────────────────────┘
                  │ HTTP/HTTPS Requests
                  │
┌─────────────────▼──────────────────────────────────────────────┐
│              LARAVEL API SERVER (Backend)                      │
│                                                                │
│ ┌──────────────────────────────────────────────────────────┐  │
│ │                    ROUTES (api.php)                     │  │
│ │                                                          │  │
│ │  POST   /api/auth/registro     → AuthController         │  │
│ │  POST   /api/auth/login        → AuthController         │  │
│ │  POST   /api/auth/logout       → AuthController (AUTH)  │  │
│ │  GET    /api/auth/perfil       → AuthController (AUTH)  │  │
│ │  PUT    /api/auth/perfil       → AuthController (AUTH)  │  │
│ │  POST   /api/auth/cambiar-pwd  → AuthController (AUTH)  │  │
│ └──────────────────────────────────────────────────────────┘  │
│                          ▲                                     │
│                          │                                     │
│ ┌────────────────────────┴───────────────────────────────┐    │
│ │              MIDDLEWARE (Protección)                  │    │
│ │                                                        │    │
│ │  ✅ auth:sanctum       → Verifica token válido       │    │
│ │  ✅ role:admin,soporte → Verifica rol específico     │    │
│ │  ✅ account.active     → Verifica cuenta activa      │    │
│ └────────────────────────┬───────────────────────────────┘    │
│                          │                                     │
│ ┌────────────────────────▼───────────────────────────────┐    │
│ │           CONTROLLERS (Lógica de Negocio)             │    │
│ │                                                        │    │
│ │  AuthController                                        │    │
│ │  ├─ registro()         → Crear usuario                │    │
│ │  ├─ login()            → Generar token                │    │
│ │  ├─ logout()           → Revocar token                │    │
│ │  ├─ perfil()           → Obtener datos               │    │
│ │  ├─ actualizarPerfil() → Actualizar info            │    │
│ │  └─ cambiarPassword()  → Cambiar contraseña         │    │
│ └────────────────────────┬───────────────────────────────┘    │
│                          │                                     │
│ ┌────────────────────────▼───────────────────────────────┐    │
│ │            MODELS (Entidades)                          │    │
│ │                                                        │    │
│ │  User (HasApiTokens)                                   │    │
│ │  ├─ Información personal (name, email, telefono)      │    │
│ │  ├─ Autenticación (password, email_verified)          │    │
│ │  ├─ Rol (tipo_usuario)                                │    │
│ │  ├─ Estado (estado_cuenta)                            │    │
│ │  └─ Relaciones (conductor, viajes, pagos, etc)       │    │
│ │                                                        │    │
│ │  Conductor                                             │    │
│ │  ├─ Documentación (licencia, vehiculo)                │    │
│ │  ├─ Desempeño (calificacion, total_viajes)           │    │
│ │  └─ Financiero (ganancias, saldo_pendiente)          │    │
│ └────────────────────────┬───────────────────────────────┘    │
│                          │                                     │
│ ┌────────────────────────▼───────────────────────────────┐    │
│ │         POLICIES (Autorización/Permisos)             │    │
│ │                                                        │    │
│ │  ConductorPolicy    → Qué puede hacer con conductores │    │
│ │  ViajePolicy        → Qué puede hacer con viajes      │    │
│ │  PagoPolicy         → Qué puede hacer con pagos       │    │
│ │                                                        │    │
│ │  Ejemplo:                                              │    │
│ │  - Pasajero NO puede ver otros pasajeros             │    │
│ │  - Conductor puede ver SUS PROPIOS viajes            │    │
│ │  - Admin puede ver TODO                              │    │
│ └────────────────────────┬───────────────────────────────┘    │
│                          │                                     │
└──────────────────────────┼──────────────────────────────────────┘
                           │
                           │ SQL Queries
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│              PostgreSQL DATABASE                               │
│                                                                │
│  ┌─────────────────────────────────────────────────────┐     │
│  │ TABLAS                                              │     │
│  │                                                     │     │
│  │ users                    (Autenticación)           │     │
│  │ ├─ id, name, email, password, tipo_usuario        │     │
│  │ ├─ estado_cuenta, email_verificado                │     │
│  │ ├─ telefono, numero_documento, ciudad             │     │
│  │ └─ intentos_fallidos_consecutivos (Seguridad)    │     │
│  │                                                     │     │
│  │ personal_access_tokens (Tokens Sanctum)            │     │
│  │ ├─ user_id, name, token, abilities                │     │
│  │ └─ last_used_at (Auditoría)                       │     │
│  │                                                     │     │
│  │ conductores                                         │     │
│  │ ├─ usuario_id (FK → users)                        │     │
│  │ ├─ numero_licencia, tipo_licencia                 │     │
│  │ ├─ estado, documentos_verificados                 │     │
│  │ └─ calificacion_promedio, total_viajes            │     │
│  └─────────────────────────────────────────────────────┘     │
└────────────────────────────────────────────────────────────────┘
```

---

## Flujo de Autenticación Step-by-Step

### 1️⃣ REGISTRO
```
Usuario → POST /api/auth/registro
    ↓
AuthController::registro()
    ↓
Validar datos (email único, password fuerte)
    ↓
Hash de contraseña con bcrypt
    ↓
Crear User en BD
    ↓
Si es conductor → Crear registro en Conductor
    ↓
Respuesta: Usuario creado (estado = verificacion)
```

### 2️⃣ LOGIN
```
Usuario → POST /api/auth/login (email + password)
    ↓
AuthController::login()
    ↓
Buscar usuario en BD por email
    ↓
Verificar contraseña con Hash::check()
    ↓
Si falla → Incrementar intentos_fallidos
    ↓
Si pasa 5 intentos → Suspender cuenta
    ↓
Verificar estado_cuenta == 'activa'
    ↓
Generar token con Sanctum: createToken()
    ↓
Actualizar ultima_sesion_exitosa
    ↓
Respuesta: Token + Datos del usuario
```

### 3️⃣ ACCESO A RUTAS PROTEGIDAS
```
Cliente → GET /api/auth/perfil + Header: Authorization: Bearer {TOKEN}
    ↓
Middleware auth:sanctum
    ↓
Sanctum valida token en tabla personal_access_tokens
    ↓
¿Token válido?
    ├─ NO → Response 401 (Unauthorized)
    └─ SÍ → Cargar usuario en $request->user()
    ↓
Middleware role:admin,soporte (si aplica)
    ↓
¿Usuario tiene rol requerido?
    ├─ NO → Response 403 (Forbidden)
    └─ SÍ → Pasar al controlador
    ↓
Middleware account.active (si aplica)
    ↓
¿Cuenta está activa?
    ├─ NO → Response 403 (Suspendida)
    └─ SÍ → Ejecutar controlador
    ↓
AuthController::perfil()
    ↓
Retornar datos del usuario autenticado
```

### 4️⃣ LOGOUT
```
Cliente → POST /api/auth/logout + Token
    ↓
Middleware auth:sanctum
    ↓
Validar token
    ↓
AuthController::logout()
    ↓
$request->user()->tokens()->delete()
    ↓
Eliminar TODOS los tokens del usuario en BD
    ↓
Respuesta: "Logout exitoso"
```

---

## Roles y Permisos

```
┌─────────────┬──────────┬──────────┬─────────────┬──────────┐
│   Acción    │  Pasajero│Conductor │   Soporte   │  Admin   │
├─────────────┼──────────┼──────────┼─────────────┼──────────┤
│ Ver perfil  │    ✅    │    ✅    │      ✅     │    ✅    │
│ Ver otros   │    ❌    │    ✅    │      ✅     │    ✅    │
│ Solicitar   │    ✅    │    ❌    │      ❌     │    ✅    │
│ Aceptar     │    ❌    │    ✅    │      ❌     │    ✅    │
│ Ver pagos   │  propios │  propios │   todos     │  todos   │
│ Procesar    │    ❌    │    ❌    │      ✅     │    ✅    │
│ Suspender   │    ❌    │    ❌    │      ❌     │    ✅    │
└─────────────┴──────────┴──────────┴─────────────┴──────────┘
```

---

## Seguridad Implementada

```
┌─────────────────────────────────────────┐
│     1. CONTRASEÑA SEGURA               │
│  Password → Hash(bcrypt) en BD        │
│  ✅ Nunca se almacena en texto plano │
│  ✅ Salt único por usuario            │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│     2. TOKEN SEGURO (Sanctum)          │
│  createToken() → Token cifrado        │
│  ✅ Token en tabla separada          │
│  ✅ Hash del token en BD             │
│  ✅ Revocable por logout            │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│   3. BLOQUEO POR INTENTOS             │
│  Intento fallido → intentos_fallidos++│
│  ✅ 5 intentos → Cuenta suspendida   │
│  ✅ Registro en BD                   │
│  ✅ Rastreo de tiempo                │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│   4. VALIDACIÓN DE ESTADO              │
│  ¿Cuenta activa?                      │
│  ✅ Verificación de email              │
│  ✅ Verificación de teléfono          │
│  ✅ Validación de documentos (conductor)
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│   5. CONTROL DE ROLES                 │
│  Middleware: role:admin,soporte       │
│  ✅ Verificación por tipo_usuario    │
│  ✅ Acceso granular a recursos      │
│  ✅ Policies para lógica compleja    │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│   6. AUDITORÍA                        │
│  ✅ ultima_sesion_exitosa registrada  │
│  ✅ ultimo_intento_fallido registrado │
│  ✅ intentos_fallidos_consecutivos   │
│  ✅ Preparado para logs_sistema       │
└─────────────────────────────────────────┘
```

---

## Integración con Flutter

```
Flutter App
    │
    ├─ Instancia de ApiClient (Dio/Http)
    │
    ├─ SharedPreferences → Guardar token
    │
    ├─ AuthProvider → Gestionar estado de autenticación
    │
    ├─ Interceptor → Agregar token a headers
    │    Authorization: Bearer {token}
    │
    └─ Refresh automático si token expira
         (Sanctum no soporta refresh nativamente)
```

---

## Próximas Mejoras

```
Fase 1 (Actual) ✅
├─ Autenticación básica
├─ Roles y permisos
└─ Usuarios de prueba

Fase 2 (Próxima)
├─ Verificación de email por OTP
├─ Verificación de teléfono por SMS
├─ Recuperación de contraseña
└─ 2FA (Two-Factor Authentication)

Fase 3
├─ OAuth 2.0 (Google, Facebook)
├─ Biometría (Face ID, Fingerprint)
└─ Rate limiting avanzado
```

---

## Referencias Rápidas

**Documentación:**
- AUTH_DOCUMENTATION.md → APIs detalladas
- AUTENTICACION_COMPLETADA.md → Resumen completado

**Archivos Clave:**
- app/Http/Controllers/Api/AuthController.php
- app/Models/User.php
- routes/api.php
- bootstrap/app.php (middleware)

**Tests:**
- test-auth.sh → Script de pruebas

---

🚀 **Arquitectura lista para producción**
