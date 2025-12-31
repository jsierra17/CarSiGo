<?php

namespace App\Http\Controllers\Api;

use App\Models\Ubicacion;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class UbicacionController
{
    /**
     * Reportar ubicación actual (en tiempo real)
     */
    public function reportar(Request $request): JsonResponse
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'latitud' => 'required|numeric|between:-90,90',
            'longitud' => 'required|numeric|between:-180,180',
            'precision' => 'sometimes|numeric|min:0',
            'velocidad' => 'sometimes|numeric|min:0',
            'rumbo' => 'sometimes|numeric|between:0,360',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $tipo = 'pasajero_en_viaje';
            $conductor_id = null;
            $pasajero_id = null;
            $viaje_id = null;

            if ($user->conductor) {
                $tipo = 'conductor';
                $conductor_id = $user->conductor->id;

                // Actualizar estado de conexión del conductor
                $user->conductor->update([
                    'estado_conexion' => 'en_linea',
                    'ultima_conexion' => now(),
                ]);

                // Si hay viaje en progreso, asociar ubicación
                $viaje = $user->conductor->viajes()
                    ->where('estado', 'en_progreso')
                    ->first();

                if ($viaje) {
                    $tipo = 'conductor';
                    $viaje_id = $viaje->id;
                }
            } else {
                $pasajero_id = $user->id;

                // Asociar a viaje en progreso del pasajero
                $viaje = $user->viajes_como_pasajero()
                    ->where('estado', 'en_progreso')
                    ->first();

                if ($viaje) {
                    $viaje_id = $viaje->id;
                }
            }

            // Crear ubicación
            $ubicacion = Ubicacion::create([
                'tipo' => $tipo,
                'conductor_id' => $conductor_id,
                'pasajero_id' => $pasajero_id,
                'viaje_id' => $viaje_id,
                'latitud' => $request->latitud,
                'longitud' => $request->longitud,
                'precision' => $request->precision,
                'velocidad' => $request->velocidad,
                'rumbo' => $request->rumbo,
                'timestamp_ubicacion' => now(),
                'proveedor' => $request->proveedor ?? 'gps',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Ubicación reportada',
                'data' => $ubicacion,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener ubicaciones recientes del conductor
     */
    public function ubicacionesConductor(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor) {
            return response()->json([
                'success' => false,
                'message' => 'No eres un conductor',
            ], 403);
        }

        // Últimas 50 ubicaciones en los últimos 30 minutos
        $ubicaciones = Ubicacion::where('conductor_id', $user->conductor->id)
            ->where('timestamp_ubicacion', '>=', now()->subMinutes(30))
            ->orderBy('timestamp_ubicacion', 'desc')
            ->limit(50)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $ubicaciones,
        ], 200);
    }

    /**
     * Buscar conductores cercanos a una ubicación
     */
    public function conductoresCercanos(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'latitud' => 'required|numeric|between:-90,90',
            'longitud' => 'required|numeric|between:-180,180',
            'radio' => 'sometimes|numeric|min:0.1|max:50', // en km
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $radio = $request->radio ?? 5; // 5 km por defecto

        try {
            $haversine = '(6371 * acos(
                    cos(radians(?)) * cos(radians(latitud)) *
                    cos(radians(longitud) - radians(?)) +
                    sin(radians(?)) * sin(radians(latitud))
                ))';

            // Fórmula de Haversine para distancia en km
            $conductores = Ubicacion::selectRaw(
                "conductor_id,\n                latitud,\n                longitud,\n                timestamp_ubicacion,\n                {$haversine} as distancia_km",
                [$request->latitud, $request->longitud, $request->latitud]
            )
            ->where('tipo', 'conductor')
            ->whereHas('conductor', function ($q) {
                $q->where('estado', 'activo')
                  ->where('estado_conexion', 'en_linea');
            })
            ->whereRaw("{$haversine} < ?", [$request->latitud, $request->longitud, $request->latitud, $radio])
            ->orderBy('distancia_km')
            ->limit(10)
            ->get();

            return response()->json([
                'success' => true,
                'data' => $conductores,
                'radio' => $radio,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error en búsqueda: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener historial de ubicaciones de un viaje
     */
    public function historicoViaje(Request $request, $viajeId): JsonResponse
    {
        $user = $request->user();

        $viaje = \App\Models\Viaje::find($viajeId);

        if (!$viaje) {
            return response()->json([
                'success' => false,
                'message' => 'Viaje no encontrado',
            ], 404);
        }

        // Verificar autorización
        if ($user->tipo_usuario === 'pasajero' && $viaje->pasajero_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        if ($user->conductor && $viaje->conductor_id !== $user->conductor->id) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        $ubicaciones = Ubicacion::where('viaje_id', $viajeId)
            ->orderBy('timestamp_ubicacion', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $ubicaciones,
            'total' => $ubicaciones->count(),
        ], 200);
    }

    /**
     * Limpiar ubicaciones antiguas (mantenimiento)
     */
    public function limpiar(): JsonResponse
    {
        try {
            // Eliminar ubicaciones más antiguas de 30 días
            $deleted = Ubicacion::where('timestamp_ubicacion', '<', now()->subDays(30))->delete();

            return response()->json([
                'success' => true,
                'message' => "Se eliminaron $deleted registros de ubicación antiguos",
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }
}
