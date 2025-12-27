# 🔐 Documentación de Autenticación - CarSiGo API

## Resumen

Sistema de autenticación basado en **Laravel Sanctum** con tokens API seguros.

---

## 📋 Usuarios de Prueba

### Admin
- **Email:** `admin@carsigo.co`
- **Password:** `Admin@123`
- **Tipo:** admin

### Soporte Técnico
- **Email:** `soporte@carsigo.co`
- **Password:** `Soporte@123`
- **Tipo:** soporte

### Conductores
1. **Email:** `conductor1@carsigo.co`
   - **Password:** `Conductor@123`
   - **Licencia:** L-1234567890
   - **Estado:** Activo
   - **Rating:** 4.8/5

2. **Email:** `conductor2@carsigo.co`
   - **Password:** `Conductor@123`
   - **Licencia:** L-1234567891
   - **Estado:** Activo
   - **Rating:** 4.5/5

### Pasajeros
1. **Email:** `pasajero1@carsigo.co`
   - **Password:** `Pasajero@123`

2. **Email:** `pasajero2@carsigo.co`
   - **Password:** `Pasajero@123`

---

## 🔑 Endpoints de Autenticación

### 1. Registro (POST)
```
POST /api/auth/registro
Content-Type: application/json

{
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "tipo_usuario": "pasajero",
  "telefono": "3001234567",
  "numero_documento": "1234567890",
  "tipo_documento": "cedula",
  "ciudad": "El Carmen de Bolívar",
  "departamento": "Bolívar",
  "pais": "Colombia"
}
```

**Respuesta (201):**
```json
{
  "success": true,
  "message": "Usuario registrado exitosamente. Por favor, verifica tu email.",
  "user": {
    "id": 3,
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "tipo_usuario": "pasajero",
    "estado_cuenta": "verificacion"
  }
}
```

**Para registrar un Conductor, agregar:**
```json
{
  "numero_licencia": "L-1234567892",
  "tipo_licencia": "B",
  "fecha_vencimiento_licencia": "2029-12-26"
}
```

---

### 2. Login (POST)
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "admin@carsigo.co",
  "password": "Admin@123"
}
```

**Respuesta (200):**
```json
{
  "success": true,
  "message": "Login exitoso",
  "token": "1|abc...xyz",
  "user": {
    "id": 1,
    "name": "José Sierra (Admin)",
    "email": "admin@carsigo.co",
    "tipo_usuario": "admin",
    "telefono": "3012345678",
    "ciudad": "El Carmen de Bolívar",
    "foto_perfil_url": null
  }
}
```

---

### 3. Obtener Perfil (GET)
```
GET /api/auth/perfil
Authorization: Bearer {token}
```

**Respuesta (200):**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "name": "José Sierra (Admin)",
    "email": "admin@carsigo.co",
    "tipo_usuario": "admin",
    "estado_cuenta": "activa",
    "telefono": "3012345678",
    "numero_documento": "1234567890",
    "tipo_documento": "cedula",
    "ciudad": "El Carmen de Bolívar",
    "departamento": "Bolívar",
    "direccion": null,
    "foto_perfil_url": null,
    "bio": null,
    "email_verificado": true,
    "telefono_verificado": true,
    "genero": null,
    "fecha_nacimiento": null,
    "recibir_notificaciones": true,
    "recibir_promociones": false
  }
}
```

---

### 4. Actualizar Perfil (PUT)
```
PUT /api/auth/perfil
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "José Sierra Actualizado",
  "bio": "Fundador de CarSiGo",
  "ciudad": "Cartagena",
  "foto_perfil_url": "https://example.com/foto.jpg",
  "recibir_notificaciones": false
}
```

**Respuesta (200):**
```json
{
  "success": true,
  "message": "Perfil actualizado exitosamente",
  "user": {
    "id": 1,
    "name": "José Sierra Actualizado",
    "email": "admin@carsigo.co",
    "telefono": "3012345678",
    "ciudad": "Cartagena",
    "bio": "Fundador de CarSiGo",
    "foto_perfil_url": "https://example.com/foto.jpg"
  }
}
```

---

### 5. Cambiar Contraseña (POST)
```
POST /api/auth/cambiar-password
Authorization: Bearer {token}
Content-Type: application/json

{
  "password_actual": "Admin@123",
  "password_nueva": "NuevaPassword@123",
  "password_nueva_confirmation": "NuevaPassword@123"
}
```

**Respuesta (200):**
```json
{
  "success": true,
  "message": "Contraseña actualizada exitosamente"
}
```

---

### 6. Logout (POST)
```
POST /api/auth/logout
Authorization: Bearer {token}
```

**Respuesta (200):**
```json
{
  "success": true,
  "message": "Logout exitoso"
}
```

---

## 🔒 Middleware de Autenticación

### 1. Autenticación (auth:sanctum)
Verifica que el usuario esté autenticado

```php
Route::middleware('auth:sanctum')->group(function () {
    // Rutas protegidas
});
```

### 2. Rol del Usuario (role)
Verifica que el usuario tenga uno de los roles especificados

```php
Route::middleware('auth:sanctum', 'role:admin,soporte')->group(function () {
    // Solo admin y soporte
});

Route::middleware('auth:sanctum', 'role:conductor')->group(function () {
    // Solo conductores
});

Route::middleware('auth:sanctum', 'role:pasajero')->group(function () {
    // Solo pasajeros
});
```

### 3. Cuenta Activa (account.active)
Verifica que la cuenta del usuario esté activa

```php
Route::middleware('auth:sanctum', 'account.active')->group(function () {
    // Solo usuarios con cuenta activa
});
```

---

## 📊 Estados de Cuenta

| Estado | Descripción |
|--------|-------------|
| `activa` | Cuenta activa y en funcionamiento |
| `inactiva` | Cuenta desactivada por el usuario |
| `suspendida` | Cuenta suspendida por violación de políticas |
| `verificacion` | Cuenta en proceso de verificación |

---

## 👥 Tipos de Usuario

| Tipo | Descripción | Permisos |
|------|-------------|----------|
| `pasajero` | Usuario que solicita viajes | Solicitar viajes, calificar |
| `conductor` | Ofrece viajes | Aceptar viajes, recibir pagos |
| `admin` | Administrador del sistema | Control total |
| `soporte` | Equipo de soporte técnico | Ver tickets, resolver incidentes |

---

## 🔐 Políticas de Autorización

### ConductorPolicy
- `viewAny()`: Admin, Soporte
- `view()`: Conductor propio, Pasajeros, Admin, Soporte
- `create()`: Cualquiera (requiere verificación)
- `update()`: Conductor propio, Admin
- `delete()`: Solo Admin
- `viewDocumentos()`: Conductor propio, Admin, Soporte
- `cambiarEstado()`: Solo Admin
- `verGanancias()`: Conductor propio, Admin, Soporte

### ViajePolicy
- `viewAny()`: Admin, Soporte
- `view()`: Pasajero propio, Conductor propio, Admin, Soporte
- `create()`: Pasajeros activos
- `update()`: Pasajero (solo antes de iniciar)
- `cancelar()`: Pasajero/Conductor (según estado)
- `aceptar()`: Conductores activos
- `completar()`: Conductor, Admin
- `calificar()`: Después de completado
- `verHistorialUbicaciones()`: Involucrados, Admin, Soporte

### PagoPolicy
- `viewAny()`: Admin, Soporte
- `view()`: Pasajero propio, Conductor propio, Admin, Soporte
- `procesar()`: Solo Admin
- `reembolsar()`: Solo Admin
- `verRecibos()`: Involucrados, Admin, Soporte

---

## 🔄 Flujo de Autenticación

```
1. Usuario envía credenciales → POST /api/auth/login
2. Sistema valida credenciales
3. Si son válidas:
   - Genera token con Sanctum
   - Actualiza última sesión
   - Retorna token y datos del usuario
4. Cliente guarda token
5. Para requests protegidos:
   Authorization: Bearer {token}
```

---

## ⚠️ Manejo de Errores

### Credenciales Inválidas (401)
```json
{
  "success": false,
  "message": "Credenciales inválidas"
}
```

### Cuenta No Activa (403)
```json
{
  "success": false,
  "message": "Tu cuenta está suspendida",
  "estado_cuenta": "suspendida"
}
```

### No Autorizado (403)
```json
{
  "message": "Unauthorized. Required role(s): admin, soporte",
  "user_role": "pasajero"
}
```

### Validación Fallida (422)
```json
{
  "success": false,
  "errors": {
    "email": ["The email has already been taken."],
    "password": ["The password must be at least 8 characters."]
  }
}
```

---

## 🛡️ Seguridad

✅ **Implementado:**
- Tokens cifrados con Sanctum
- Contraseñas hasheadas con bcrypt
- Bloqueo por intentos fallidos (5 intentos = suspensión)
- Validación de estado de cuenta
- Middleware de roles y permisos
- Auditoría de sesiones
- Rate limiting (a implementar en próximas fases)

---

## 📝 Notas Importantes

1. **Tokens API**: Los tokens se genera con `createToken()` y tienen validez indefinida hasta que se revoquen

2. **Rate Limiting**: Implementar en producción para evitar ataques de fuerza bruta

3. **Email Verification**: Agregar verificación de email en producción

4. **2FA**: Considerar implementar autenticación de dos factores para admin y soporte

5. **Refresh Tokens**: Laravel Sanctum no soporta refresh tokens nativamente; considerar usar Passport si es necesario

---

## 🚀 Próximas Fases

- [ ] Implementación de 2FA
- [ ] OAuth 2.0 para login social
- [ ] Recuperación de contraseña por email
- [ ] Verificación de teléfono por SMS
- [ ] Rate limiting en API
- [ ] Auditoría completa de accesos
