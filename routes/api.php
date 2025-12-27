<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ViajeController;
use App\Http\Controllers\Api\UbicacionController;
use App\Http\Controllers\Api\PagoController;
use App\Http\Controllers\Api\ConductorController;
use App\Http\Controllers\Api\SoporteController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Middleware\EnsureWalletActive;

// Rutas de autenticación (públicas)
Route::post('/auth/registro', [AuthController::class, 'registro']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Rutas protegidas (requieren token)
Route::middleware('auth:sanctum')->group(function () {
    // Autenticación
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/perfil', [AuthController::class, 'perfil']);
    Route::put('/auth/perfil', [AuthController::class, 'actualizarPerfil']);
    Route::post('/auth/cambiar-password', [AuthController::class, 'cambiarPassword']);
    
    // Ruta de prueba
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // ========================
    // RUTAS DE VIAJES
    // ========================
    Route::prefix('viajes')->group(function () {
        Route::get('/', [ViajeController::class, 'index']); // Listar viajes
        Route::post('/', [ViajeController::class, 'store']); // Crear viaje
        Route::get('/disponibles', [ViajeController::class, 'viajesDisponibles']); // Viajes disponibles para conductores
        Route::get('/{viaje}', [ViajeController::class, 'show']); // Ver detalles viaje
        Route::patch('/{viaje}', [ViajeController::class, 'update']); // Actualizar viaje (pasajero)
        
        // Acciones de viaje
        Route::patch('/{viaje}/aceptar', [ViajeController::class, 'aceptar'])->middleware(EnsureWalletActive::class); // Conductor acepta viaje (valida wallet)
        Route::patch('/{viaje}/iniciar', [ViajeController::class, 'iniciar'])->middleware(EnsureWalletActive::class); // Conductor inicia viaje (valida wallet)
        Route::patch('/{viaje}/completar', [ViajeController::class, 'completar'])->middleware(EnsureWalletActive::class); // Conductor completa viaje (valida wallet)
        Route::patch('/{viaje}/cancelar', [ViajeController::class, 'cancelar']); // Cancelar viaje
        Route::post('/{viaje}/calificar', [ViajeController::class, 'calificar']); // Calificar viaje
        
        // Ubicaciones del viaje
        Route::get('/{viaje}/ubicaciones', [ViajeController::class, 'ubicacionesViaje']); // Historial de ubicaciones
    });

    // ========================
    // RUTAS DE UBICACIONES
    // ========================
    Route::prefix('ubicaciones')->group(function () {
        Route::post('/reportar', [UbicacionController::class, 'reportar']); // Reportar ubicación actual
        Route::get('/conductor/recientes', [UbicacionController::class, 'ubicacionesConductor']); // Ubicaciones recientes del conductor
        Route::get('/conductores/cercanos', [UbicacionController::class, 'conductoresCercanos']); // Conductores cercanos
        Route::get('/viajes/{viaje}/historico', [UbicacionController::class, 'historicoViaje']); // Historial de ubicaciones de viaje
        Route::delete('/limpiar', [UbicacionController::class, 'limpiar']); // Limpiar ubicaciones antiguas (mantenimiento)
    });

    // ========================
    // RUTAS DE PAGOS
    // ========================
    Route::prefix('pagos')->group(function () {
        Route::get('/', [PagoController::class, 'index']); // Listar pagos
        Route::get('/{pago}', [PagoController::class, 'show']); // Ver detalles pago
        Route::post('/viajes/{viaje}/procesar', [PagoController::class, 'procesarViaje']); // Procesar pago de viaje
        Route::post('/{pago}/reembolsar', [PagoController::class, 'reembolsar']); // Reembolsar pago
        Route::get('/resumen/ganancias', [PagoController::class, 'resumenGanancias']); // Resumen de ganancias
        Route::get('/{pago}/recibo', [PagoController::class, 'recibo']); // Descargar recibo
    });

    // ========================
    // RUTAS DE CONDUCTORES
    // ========================
    Route::prefix('conductores')->group(function () {
        Route::get('/', [ConductorController::class, 'index']); // Listar conductores (admin/soporte)
        Route::get('/mi-perfil', [ConductorController::class, 'miPerfil']); // Mi perfil como conductor
        Route::get('/{conductor}', [ConductorController::class, 'show']); // Ver perfil de conductor
        Route::put('/mi-perfil', [ConductorController::class, 'actualizarPerfil']); // Actualizar mi perfil
        Route::patch('/{conductor}/estado', [ConductorController::class, 'cambiarEstado']); // Cambiar estado (admin)
        Route::patch('/mi-estado-conexion', [ConductorController::class, 'cambiarEstadoConexion']); // Cambiar estado conexión
        
        // Documentos
        Route::get('/documentos', [ConductorController::class, 'documentos']); // Ver documentos
        Route::post('/documentos/subir', [ConductorController::class, 'subirDocumento']); // Subir documento
        
        // Ganancias y calificaciones
        Route::get('/ganancias', [ConductorController::class, 'ganancias']); // Ver ganancias
        Route::get('/calificaciones', [ConductorController::class, 'calificaciones']); // Ver calificaciones
    });

    // ========================
    // RUTAS DE SOPORTE
    // ========================
    Route::prefix('soporte')->group(function () {
        Route::get('/tickets', [SoporteController::class, 'index']); // Listar tickets
        Route::post('/tickets', [SoporteController::class, 'store']); // Crear ticket
        Route::get('/tickets/{ticket}', [SoporteController::class, 'show']); // Ver ticket
        Route::post('/tickets/{ticket}/responder', [SoporteController::class, 'responder']); // Responder ticket
        Route::patch('/tickets/{ticket}/estado', [SoporteController::class, 'actualizarEstado']); // Cambiar estado (admin/soporte)
        Route::patch('/tickets/{ticket}/asignar', [SoporteController::class, 'asignar']); // Asignar ticket (admin)
        Route::get('/estadisticas', [SoporteController::class, 'estadisticas']); // Estadísticas (admin/soporte)
    });

    // ========================
    // RUTAS DE BILLETERA (WALLET)
    // ========================
    Route::prefix('wallet')->group(function () {
        Route::get('/balance', [WalletController::class, 'balance']); // Ver balance actual
        Route::get('/historial', [WalletController::class, 'historial']); // Historial de transacciones
        Route::get('/resumen', [WalletController::class, 'resumen']); // Resumen financiero
        Route::post('/recargar', [WalletController::class, 'recargar']); // Iniciar recarga de saldo
        Route::post('/confirmar-recarga', [WalletController::class, 'confirmarRecarga']); // Confirmar recarga (webhook)
    });
});
