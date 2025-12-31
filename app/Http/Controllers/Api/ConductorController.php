<?php

namespace App\Http\Controllers\Api;

use App\Models\Conductor;
use App\Models\Pago;
use App\Models\Viaje;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class ConductorController
{
    /**
     * Listar conductores (admin/soporte)
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!in_array($user->tipo_usuario, ['admin', 'soporte'])) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        $conductores = Conductor::with(['usuario:id,name,email,telefono,foto_perfil_url'])
            ->when($request->estado, function ($query) {
                return $query->where('estado', $request->estado);
            })
            ->when($request->buscar, function ($query) {
                return $query->whereHas('usuario', function ($q) {
                    $q->where('name', 'like', '%' . request('buscar') . '%')
                        ->orWhere('email', 'like', '%' . request('buscar') . '%');
                });
            })
            ->orderBy('calificacion_promedio', 'desc')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $conductores,
        ], 200);
    }

    /**
     * Ver perfil del conductor autenticado
     */
    public function miPerfil(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor) {
            return response()->json([
                'success' => false,
                'message' => 'No eres un conductor',
            ], 403);
        }

        $conductor = $user->conductor->load([
            'usuario:id,name,email,telefono,foto_perfil_url,numero_documento,fecha_nacimiento',
            'vehiculos:id,conductor_id,placa,marca,modelo,anio,color,categoria',
        ]);

        return response()->json([
            'success' => true,
            'data' => $conductor,
        ], 200);
    }

    /**
     * Ver perfil de otro conductor (público)
     */
    public function show(Conductor $conductor): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $conductor->load('usuario:id,name,foto_perfil_url,ciudad'),
        ], 200);
    }

    /**
     * Actualizar perfil del conductor
     */
    public function actualizarPerfil(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor) {
            return response()->json([
                'success' => false,
                'message' => 'No eres un conductor',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'numero_licencia' => 'sometimes|string|unique:conductores,numero_licencia,' . $user->conductor->id,
            'fecha_vencimiento_licencia' => 'sometimes|date|after:today',
            'tipo_licencia' => 'sometimes|in:B,C,D,E',
            'ciudad_expedicion' => 'sometimes|string|max:100',
            'banco' => 'sometimes|string|max:100',
            'numero_cuenta' => 'sometimes|string|max:50',
            'tipo_cuenta' => 'sometimes|in:ahorros,corriente',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $user->conductor->update($validator->validated());

            return response()->json([
                'success' => true,
                'message' => 'Perfil actualizado exitosamente',
                'data' => $user->conductor,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar perfil: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Cambiar estado del conductor (admin)
     */
    public function cambiarEstado(Request $request, Conductor $conductor): JsonResponse
    {
        $user = $request->user();

        if ($user->tipo_usuario !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Solo administradores pueden cambiar estado',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'estado' => 'required|in:activo,inactivo,suspendido',
            'razon' => 'sometimes|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $estado_anterior = $conductor->estado;
            $conductor->update([
                'estado' => $request->estado,
            ]);

            // Registrar en logs
            DB::table('logs_sistema')->insert([
                'usuario_id' => $user->id,
                'tipo_evento' => 'otro',
                'modulo' => 'conductores',
                'accion' => 'cambio_estado_conductor',
                'descripcion' => "Conductor {$conductor->usuario_id} cambió de {$estado_anterior} a {$request->estado}. Razón: {$request->razon}",
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'estado' => 'info',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Estado actualizado exitosamente',
                'data' => $conductor,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al cambiar estado: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Cambiar estado de conexión (conductor activo)
     */
    public function cambiarEstadoConexion(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor) {
            return response()->json([
                'success' => false,
                'message' => 'No eres un conductor',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'estado_conexion' => 'required|in:en_linea,fuera_linea,en_viaje',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $user->conductor->update([
                'estado_conexion' => $request->estado_conexion,
                'ultima_conexion' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Estado de conexión actualizado',
                'data' => [
                    'estado_conexion' => $user->conductor->estado_conexion,
                    'ultima_conexion' => $user->conductor->ultima_conexion,
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar estado: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener documentos del conductor
     */
    public function documentos(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor && $user->tipo_usuario !== 'admin' && $user->tipo_usuario !== 'soporte') {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        $documentos = [
            'licencia' => [
                'numero' => $user->conductor->numero_licencia,
                'tipo' => $user->conductor->tipo_licencia,
                'vencimiento' => $user->conductor->fecha_vencimiento_licencia,
                'estado' => $this->verificarDocumentoVigente($user->conductor->fecha_vencimiento_licencia),
            ],
            'antecedentes' => [
                'verificado' => $user->conductor->antecedentes_limpios,
                'fecha_verificacion' => $user->conductor->fecha_ultima_verificacion,
            ],
            'seguro_vehiculo' => [
                'activo' => $user->conductor->numero_aseguranza ? true : false,
            ],
        ];

        return response()->json([
            'success' => true,
            'data' => $documentos,
        ], 200);
    }

    /**
     * Subir documento
     */
    public function subirDocumento(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor) {
            return response()->json([
                'success' => false,
                'message' => 'No eres un conductor',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'tipo_documento' => 'required|in:licencia,cedula,seguro,inspeccion_tecnica',
            'archivo' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $ruta = 'documentos/conductores/' . $user->conductor->id;
            $archivo = $request->file('archivo');
            $nombre_archivo = $request->tipo_documento . '-' . time() . '.' . $archivo->getClientOriginalExtension();

            Storage::disk('private')->putFileAs($ruta, $archivo, $nombre_archivo);

            return response()->json([
                'success' => true,
                'message' => 'Documento cargado exitosamente',
                'data' => [
                    'tipo' => $request->tipo_documento,
                    'archivo' => $nombre_archivo,
                    'fecha_carga' => now(),
                ],
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al cargar documento: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener ganancias del conductor
     */
    public function ganancias(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor && $user->tipo_usuario !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        $conductor_id = $user->conductor ? $user->conductor->id : $request->query('conductor_id');

        if (!$conductor_id) {
            return response()->json([
                'success' => false,
                'message' => 'ID de conductor requerido',
            ], 400);
        }

        $conductor = Conductor::find($conductor_id);

        if (!$conductor) {
            return response()->json([
                'success' => false,
                'message' => 'Conductor no encontrado',
            ], 404);
        }

        $periodo = $request->query('periodo', 'mes'); // mes, semana, año
        $fecha_inicio = $this->obtenerFechaInicio($periodo);

        $pagos = Pago::where('conductor_id', $conductor_id)
            ->where('estado', 'completado')
            ->where('fecha_completacion', '>=', $fecha_inicio)
            ->get();

        $ganancias = [
            'periodo' => $periodo,
            'total_viajes' => $pagos->count(),
            'ganancias_brutas' => $pagos->sum('monto_total'),
            'comisiones_plataforma' => $pagos->sum('comision_plataforma'),
            'ganancias_netas' => $pagos->sum('monto_conductor'),
            'promedio_por_viaje' => $pagos->count() > 0 ? round($pagos->sum('monto_conductor') / $pagos->count(), 2) : 0,
            'viajes' => $pagos->map(function ($pago) {
                return [
                    'id' => $pago->id,
                    'viaje_id' => $pago->viaje_id,
                    'fecha' => $pago->fecha_completacion,
                    'monto_total' => $pago->monto_total,
                    'comision' => $pago->comision_plataforma,
                    'monto_neto' => $pago->monto_conductor,
                ];
            })->toArray(),
        ];

        return response()->json([
            'success' => true,
            'data' => $ganancias,
        ], 200);
    }

    /**
     * Historial de calificaciones
     */
    public function calificaciones(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor) {
            return response()->json([
                'success' => false,
                'message' => 'No eres un conductor',
            ], 403);
        }

        $viajes = Viaje::where('conductor_id', $user->conductor->id)
            ->whereNotNull('calificacion_conductor')
            ->with(['pasajero:id,name,foto_perfil_url'])
            ->orderBy('hora_finalizacion', 'desc')
            ->paginate(20);

        $estadisticas = [
            'promedio_general' => $user->conductor->calificacion_promedio,
            'total_calificaciones' => $viajes->total(),
            'distribucion' => [
                '5_estrellas' => $viajes->where('calificacion_conductor', 5)->count(),
                '4_estrellas' => $viajes->where('calificacion_conductor', 4)->count(),
                '3_estrellas' => $viajes->where('calificacion_conductor', 3)->count(),
                '2_estrellas' => $viajes->where('calificacion_conductor', 2)->count(),
                '1_estrella' => $viajes->where('calificacion_conductor', 1)->count(),
            ],
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'estadisticas' => $estadisticas,
                'calificaciones' => $viajes,
            ],
        ], 200);
    }

    // Métodos auxiliares privados

    private function verificarDocumentoVigente($fecha_vencimiento): string
    {
        if (!$fecha_vencimiento) {
            return 'no_registrado';
        }

        $dias_restantes = now()->diffInDays($fecha_vencimiento);

        if ($dias_restantes < 0) {
            return 'vencido';
        } elseif ($dias_restantes < 30) {
            return 'proximo_a_vencer';
        }

        return 'vigente';
    }

    private function obtenerFechaInicio(string $periodo)
    {
        return match ($periodo) {
            'semana' => now()->subWeek(),
            'año' => now()->subYear(),
            default => now()->subMonth(), // mes por defecto
        };
    }
}
