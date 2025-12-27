# Script de prueba de endpoints de CarSiGo
# Versión PowerShell

$BaseURL = "http://127.0.0.1:8000/api"
$PasajeroEmail = "pasajero1@carsigo.co"
$PasajeroPassword = "Pasajero@123"
$ConductorEmail = "conductor1@carsigo.co"
$ConductorPassword = "Conductor@123"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "🚀 PRUEBA DE ENDPOINTS - CarSiGo" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 1. Login Pasajero
Write-Host "1️⃣  Realizando login como pasajero..." -ForegroundColor Yellow

try {
    $loginResponse = Invoke-RestMethod -Uri "$BaseURL/auth/login" -Method Post `
        -ContentType "application/json" `
        -Body (@{
            email = $PasajeroEmail
            password = $PasajeroPassword
        } | ConvertTo-Json)
    
    $PasajeroToken = $loginResponse.data.token
    Write-Host "✅ Login exitoso!" -ForegroundColor Green
    Write-Host "Token: $($PasajeroToken.Substring(0, [Math]::Min(20, $PasajeroToken.Length)))..." -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "❌ Error en login pasajero: $_" -ForegroundColor Red
    exit 1
}

# 2. Login Conductor
Write-Host "2️⃣  Realizando login como conductor..." -ForegroundColor Yellow

try {
    $conductorLoginResponse = Invoke-RestMethod -Uri "$BaseURL/auth/login" -Method Post `
        -ContentType "application/json" `
        -Body (@{
            email = $ConductorEmail
            password = $ConductorPassword
        } | ConvertTo-Json)
    
    $ConductorToken = $conductorLoginResponse.data.token
    Write-Host "✅ Login exitoso!" -ForegroundColor Green
    Write-Host "Token: $($ConductorToken.Substring(0, [Math]::Min(20, $ConductorToken.Length)))..." -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "❌ Error en login conductor: $_" -ForegroundColor Red
    exit 1
}

# 3. Pasajero solicita viaje
Write-Host "3️⃣  Pasajero solicita un viaje..." -ForegroundColor Yellow

try {
    $viajeBody = @{
        origen_latitud = 10.4023
        origen_longitud = -75.5156
        destino_latitud = 10.4115
        destino_longitud = -75.5078
        origen_direccion = "Calle 1, El Carmen"
        destino_direccion = "Calle 5, El Carmen"
        distancia_estimada = 2.5
        duracion_estimada = 600
    } | ConvertTo-Json

    $viajeResponse = Invoke-RestMethod -Uri "$BaseURL/viajes" -Method Post `
        -Headers @{ Authorization = "Bearer $PasajeroToken" } `
        -ContentType "application/json" `
        -Body $viajeBody
    
    $ViajeID = $viajeResponse.data.id
    Write-Host "✅ Viaje creado!" -ForegroundColor Green
    Write-Host "ID del viaje: $ViajeID" -ForegroundColor Gray
    Write-Host "Estado: $($viajeResponse.data.estado)" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "❌ Error al crear viaje: $_" -ForegroundColor Red
    exit 1
}

# 4. Conductor reporta ubicación
Write-Host "4️⃣  Conductor reporta ubicación..." -ForegroundColor Yellow

try {
    $ubicacionBody = @{
        latitud = 10.4025
        longitud = -75.5150
    } | ConvertTo-Json

    $ubicacionResponse = Invoke-RestMethod -Uri "$BaseURL/ubicaciones/reportar" -Method Post `
        -Headers @{ Authorization = "Bearer $ConductorToken" } `
        -ContentType "application/json" `
        -Body $ubicacionBody
    
    Write-Host "✅ Ubicación reportada!" -ForegroundColor Green
    Write-Host "Lat: $($ubicacionResponse.data.latitud), Long: $($ubicacionResponse.data.longitud)" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "❌ Error al reportar ubicación: $_" -ForegroundColor Red
    exit 1
}

# 5. Conductor busca viajes disponibles
Write-Host "5️⃣  Conductor busca viajes disponibles..." -ForegroundColor Yellow

try {
    $disponiblesResponse = Invoke-RestMethod -Uri "$BaseURL/viajes/disponibles" -Method Get `
        -Headers @{ Authorization = "Bearer $ConductorToken" }
    
    $count = $disponiblesResponse.data.Count
    Write-Host "✅ Viajes disponibles encontrados: $count" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host "❌ Error al buscar viajes: $_" -ForegroundColor Red
    exit 1
}

# 6. Conductor acepta viaje
Write-Host "6️⃣  Conductor acepta el viaje..." -ForegroundColor Yellow

try {
    $aceptarResponse = Invoke-RestMethod -Uri "$BaseURL/viajes/$ViajeID/aceptar" -Method Patch `
        -Headers @{ Authorization = "Bearer $ConductorToken" } `
        -ContentType "application/json" `
        -Body '{}'
    
    Write-Host "✅ Viaje aceptado!" -ForegroundColor Green
    Write-Host "Nuevo estado: $($aceptarResponse.data.estado)" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "❌ Error al aceptar viaje: $_" -ForegroundColor Red
    exit 1
}

# 7. Conductor inicia viaje
Write-Host "7️⃣  Conductor inicia el viaje..." -ForegroundColor Yellow

try {
    $iniciarResponse = Invoke-RestMethod -Uri "$BaseURL/viajes/$ViajeID/iniciar" -Method Patch `
        -Headers @{ Authorization = "Bearer $ConductorToken" } `
        -ContentType "application/json" `
        -Body '{}'
    
    Write-Host "✅ Viaje iniciado!" -ForegroundColor Green
    Write-Host "Estado: $($iniciarResponse.data.estado)" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "❌ Error al iniciar viaje: $_" -ForegroundColor Red
    exit 1
}

# 8. Conductor completa viaje
Write-Host "8️⃣  Conductor completa el viaje..." -ForegroundColor Yellow

try {
    $completarResponse = Invoke-RestMethod -Uri "$BaseURL/viajes/$ViajeID/completar" -Method Patch `
        -Headers @{ Authorization = "Bearer $ConductorToken" } `
        -ContentType "application/json" `
        -Body (@{ 
            destino_latitud = 10.4115
            destino_longitud = -75.5078
        } | ConvertTo-Json)
    
    Write-Host "✅ Viaje completado!" -ForegroundColor Green
    Write-Host "Estado: $($completarResponse.data.estado)" -ForegroundColor Gray
    Write-Host "Precio total: $($completarResponse.data.precio_total)" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "❌ Error al completar viaje: $_" -ForegroundColor Red
    exit 1
}

# 9. Procesar pago
Write-Host "9️⃣  Procesando pago del viaje..." -ForegroundColor Yellow

try {
    $pagoResponse = Invoke-RestMethod -Uri "$BaseURL/pagos/viajes/$ViajeID/procesar" -Method Post `
        -Headers @{ Authorization = "Bearer $PasajeroToken" } `
        -ContentType "application/json" `
        -Body '{}'
    
    Write-Host "✅ Pago procesado!" -ForegroundColor Green
    Write-Host "Monto total: $($pagoResponse.data.monto_total)" -ForegroundColor Gray
    Write-Host "Comisión: $($pagoResponse.data.comision_plataforma)" -ForegroundColor Gray
    Write-Host "Estado: $($pagoResponse.data.estado)" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "❌ Error al procesar pago: $_" -ForegroundColor Red
    exit 1
}

# 10. Pasajero califica viaje
Write-Host "🔟 Pasajero califica el viaje..." -ForegroundColor Yellow

try {
    $calificacionResponse = Invoke-RestMethod -Uri "$BaseURL/viajes/$ViajeID/calificar" -Method Post `
        -Headers @{ Authorization = "Bearer $PasajeroToken" } `
        -ContentType "application/json" `
        -Body (@{
            calificacion = 5
            comentario = "Excelente servicio, muy puntual"
        } | ConvertTo-Json)
    
    Write-Host "✅ Viaje calificado!" -ForegroundColor Green
    Write-Host "Calificación: $($calificacionResponse.data.calificacion) estrellas" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "❌ Error al calificar viaje: $_" -ForegroundColor Red
    exit 1
}

# 11. Ver perfil del conductor
Write-Host "1️⃣1️⃣  Obteniendo perfil del conductor..." -ForegroundColor Yellow

try {
    $perfilResponse = Invoke-RestMethod -Uri "$BaseURL/conductores/mi-perfil" -Method Get `
        -Headers @{ Authorization = "Bearer $ConductorToken" }
    
    Write-Host "✅ Perfil obtenido!" -ForegroundColor Green
    Write-Host "Nombre: $($perfilResponse.data.usuario.nombre)" -ForegroundColor Gray
    Write-Host "Ganancias totales: $($perfilResponse.data.ganancias_totales)" -ForegroundColor Gray
    Write-Host "Rating: $($perfilResponse.data.calificacion_promedio) ⭐" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "❌ Error al obtener perfil: $_" -ForegroundColor Red
    exit 1
}

# 12. Crear ticket de soporte
Write-Host "1️⃣2️⃣  Creando ticket de soporte..." -ForegroundColor Yellow

try {
    $soporteBody = @{
        titulo = "Problema con la factura"
        descripcion = "No puedo ver el recibo del último viaje"
        categoria = "pago"
        prioridad = "normal"
    } | ConvertTo-Json

    $soporteResponse = Invoke-RestMethod -Uri "$BaseURL/soporte/tickets" -Method Post `
        -Headers @{ Authorization = "Bearer $PasajeroToken" } `
        -ContentType "application/json" `
        -Body $soporteBody
    
    Write-Host "✅ Ticket creado!" -ForegroundColor Green
    Write-Host "Número de ticket: $($soporteResponse.data.numero_ticket)" -ForegroundColor Gray
    Write-Host "Estado: $($soporteResponse.data.estado)" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "❌ Error al crear ticket: $_" -ForegroundColor Red
    exit 1
}

# Resumen final
Write-Host "======================================" -ForegroundColor Green
Write-Host "✅ ¡TODAS LAS PRUEBAS PASARON!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Resumen de pruebas completadas:" -ForegroundColor Cyan
Write-Host "  ✅ Login pasajero" -ForegroundColor Green
Write-Host "  ✅ Login conductor" -ForegroundColor Green
Write-Host "  ✅ Crear viaje" -ForegroundColor Green
Write-Host "  ✅ Reportar ubicación" -ForegroundColor Green
Write-Host "  ✅ Buscar viajes disponibles" -ForegroundColor Green
Write-Host "  ✅ Aceptar viaje" -ForegroundColor Green
Write-Host "  ✅ Iniciar viaje" -ForegroundColor Green
Write-Host "  ✅ Completar viaje" -ForegroundColor Green
Write-Host "  ✅ Procesar pago" -ForegroundColor Green
Write-Host "  ✅ Calificar viaje" -ForegroundColor Green
Write-Host "  ✅ Obtener perfil conductor" -ForegroundColor Green
Write-Host "  ✅ Crear ticket soporte" -ForegroundColor Green
Write-Host ""
Write-Host "El API esta completamente funcional!" -ForegroundColor Cyan
