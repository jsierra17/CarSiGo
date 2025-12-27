<?php

namespace App\Http\Controllers\Api;

use App\Models\Viaje;
use App\Models\Conductor;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class ViajeController
{
    /**
     * Listar viajes del usuario autenticado
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Viaje::query();

        if ($user->tipo_usuario === 'pasajero') {
            // Pasajero ve solo sus viajes
            $query->where('pasajero_id', $user->id);
        } elseif ($user->conductor) {
            // Conductor ve solo sus viajes
            $query->where('conductor_id', $user->conductor->id);
        } elseif (!in_array($user->tipo_usuario, ['admin', 'soporte'])) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        $viajes = $query->with(['pasajero:id,name,telefono', 'conductor:id'])->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $viajes,
        ], 200);
    }

    /**
     * Ver detalles de un viaje específico
     */
    public function show(Request $request, Viaje $viaje): JsonResponse
    {
        $user = $request->user();

        // Verificar autorización
        if ($user->tipo_usuario === 'pasajero' && $viaje->pasajero_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado para ver este viaje',
            ], 403);
        }

        if ($user->conductor && $viaje->conductor_id !== $user->conductor->id) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado para ver este viaje',
            ], 403);
        }

        $viaje->load(['pasajero:id,name,telefono,ciudad', 'conductor.usuario:id,name,telefono']);

        return response()->json([
            'success' => true,
            'data' => $viaje,
        ], 200);
    }

    /**
     * Solicitar nuevo viaje
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        // Solo pasajeros pueden solicitar viajes
        if ($user->tipo_usuario !== 'pasajero') {
            return response()->json([
                'success' => false,
                'message' => 'Solo pasajeros pueden solicitar viajes',
            ], 403);
        }

        // Validar datos
        $validator = Validator::make($request->all(), [
            'origen_latitud' => 'required|numeric|between:-90,90',
            'origen_longitud' => 'required|numeric|between:-180,180',
            'origen_direccion' => 'required|string|max:255',
            'destino_latitud' => 'required|numeric|between:-90,90',
            'destino_longitud' => 'required|numeric|between:-180,180',
            'destino_direccion' => 'required|string|max:255',
            'tipo' => 'sometimes|in:estandar,compartido,urgente',
            'pasajeros_solicitados' => 'sometimes|integer|min:1|max:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // Crear viaje
            $viaje = Viaje::create([
                'pasajero_id' => $user->id,
                'origen_latitud' => $request->origen_latitud,
                'origen_longitud' => $request->origen_longitud,
                'origen_direccion' => $request->origen_direccion,
                'origen_lugar' => $request->origen_lugar,
                'destino_latitud' => $request->destino_latitud,
                'destino_longitud' => $request->destino_longitud,
                'destino_direccion' => $request->destino_direccion,
                'destino_lugar' => $request->destino_lugar,
                'tipo' => $request->tipo ?? 'estandar',
                'pasajeros_solicitados' => $request->pasajeros_solicitados ?? 1,
                'tarifa_base' => 2500, // De configuración
                'estado' => 'solicitado',
                'hora_solicitud' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Viaje solicitado exitosamente',
                'data' => $viaje->load('pasajero:id,name,telefono'),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al solicitar viaje: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Listar viajes disponibles para conductores
     */
    public function viajesDisponibles(Request $request): JsonResponse
    {
        $user = $request->user();

        // Solo conductores activos
        if (!$user->conductor || $user->conductor->estado !== 'activo') {
            return response()->json([
                'success' => false,
                'message' => 'Debes ser un conductor activo',
            ], 403);
        }

        $viajes = Viaje::where('estado', 'solicitado')
            ->where('conductor_id', null)
            ->orderBy('hora_solicitud', 'desc')
            ->with('pasajero:id,name,telefono')
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $viajes,
        ], 200);
    }

    /**
     * Aceptar viaje (conductor)
     */
    public function aceptar(Request $request, Viaje $viaje): JsonResponse
    {
        $user = $request->user();

        // Solo conductores activos
        if (!$user->conductor || $user->conductor->estado !== 'activo') {
            return response()->json([
                'success' => false,
                'message' => 'Debes ser un conductor activo',
            ], 403);
        }

        // Validar estado del viaje
        if ($viaje->estado !== 'solicitado') {
            return response()->json([
                'success' => false,
                'message' => 'Este viaje no está disponible',
            ], 400);
        }

        try {
            $viaje->update([
                'conductor_id' => $user->conductor->id,
                'estado' => 'asignado',
                'hora_asignacion' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Viaje aceptado exitosamente',
                'data' => $viaje->load('pasajero:id,name,telefono,ciudad'),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al aceptar viaje: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Iniciar viaje (conductor)
     */
    public function iniciar(Request $request, Viaje $viaje): JsonResponse
    {
        $user = $request->user();

        // Verificar que sea el conductor asignado
        if (!$user->conductor || $viaje->conductor_id !== $user->conductor->id) {
            return response()->json([
                'success' => false,
                'message' => 'No eres el conductor asignado a este viaje',
            ], 403);
        }

        if ($viaje->estado !== 'asignado') {
            return response()->json([
                'success' => false,
                'message' => 'El viaje debe estar asignado para iniciarlo',
            ], 400);
        }

        try {
            $viaje->update([
                'estado' => 'en_progreso',
                'hora_inicio' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Viaje iniciado',
                'data' => $viaje,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Completar viaje
     */
    public function completar(Request $request, Viaje $viaje): JsonResponse
    {
        $user = $request->user();

        // Validar autorización
        if ($user->conductor && $viaje->conductor_id !== $user->conductor->id) {
            return response()->json([
                'success' => false,
                'message' => 'No eres el conductor de este viaje',
            ], 403);
        }

        if ($viaje->estado !== 'en_progreso') {
            return response()->json([
                'success' => false,
                'message' => 'El viaje debe estar en progreso',
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'distancia_estimada' => 'required|numeric|min:0.1',
            'duracion_estimada' => 'required|integer|min:60',
            'precio_total' => 'required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $viaje->update([
                'distancia_estimada' => $request->distancia_estimada,
                'duracion_estimada' => $request->duracion_estimada,
                'precio_total' => $request->precio_total,
                'estado' => 'completado',
                'hora_finalizacion' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Viaje completado',
                'data' => $viaje,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Cancelar viaje
     */
    public function cancelar(Request $request, Viaje $viaje): JsonResponse
    {
        $user = $request->user();
        $razon = $request->razon_cancelacion ?? 'Sin especificar';

        // Validar autorización
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

        // Validar estado
        if (!in_array($viaje->estado, ['solicitado', 'asignado', 'conductor_en_ruta'])) {
            return response()->json([
                'success' => false,
                'message' => 'No se puede cancelar un viaje en este estado',
            ], 400);
        }

        try {
            $viaje->update([
                'estado' => 'cancelado',
                'razon_cancelacion' => $razon,
                'cancelado_por' => $user->tipo_usuario,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Viaje cancelado',
                'data' => $viaje,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Calificar viaje
     */
    public function calificar(Request $request, Viaje $viaje): JsonResponse
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'calificacion' => 'required|integer|min:1|max:5',
            'comentario' => 'sometimes|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        if ($viaje->estado !== 'completado') {
            return response()->json([
                'success' => false,
                'message' => 'Solo se pueden calificar viajes completados',
            ], 400);
        }

        try {
            if ($user->tipo_usuario === 'pasajero' && $viaje->pasajero_id === $user->id) {
                $viaje->update([
                    'calificacion_pasajero' => $request->calificacion,
                    'comentario_pasajero' => $request->comentario,
                ]);
            } elseif ($user->conductor && $viaje->conductor_id === $user->conductor->id) {
                $viaje->update([
                    'calificacion_conductor' => $request->calificacion,
                    'comentario_conductor' => $request->comentario,
                ]);

                // Actualizar promedio de conductor
                $promedio = Viaje::where('conductor_id', $user->conductor->id)
                    ->where('calificacion_conductor', '!=', null)
                    ->avg('calificacion_conductor');

                $user->conductor->update([
                    'calificacion_promedio' => $promedio,
                    'total_calificaciones' => Viaje::where('conductor_id', $user->conductor->id)
                        ->where('calificacion_conductor', '!=', null)
                        ->count(),
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'No autorizado para calificar este viaje',
                ], 403);
            }

            return response()->json([
                'success' => true,
                'message' => 'Calificación registrada',
                'data' => $viaje,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Historial de ubicaciones de un viaje
     */
    public function ubicacionesViaje(Request $request, Viaje $viaje): JsonResponse
    {
        $user = $request->user();

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

        $ubicaciones = $viaje->ubicaciones()->orderBy('timestamp_ubicacion')->get();

        return response()->json([
            'success' => true,
            'data' => $ubicaciones,
        ], 200);
    }
}
