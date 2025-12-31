<?php

namespace App\Http\Controllers\Api;

use App\Models\SoporteTicket;
use App\Models\Viaje;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class SoporteController
{
    /**
     * Listar tickets de soporte
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = SoporteTicket::query();

        if ($user->tipo_usuario === 'pasajero' || $user->tipo_usuario === 'conductor') {
            $query->where('usuario_id', $user->id);
        } elseif (!in_array($user->tipo_usuario, ['admin', 'soporte'])) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        $tickets = $query->with(['usuario:id,name,email,telefono,foto_perfil_url', 'viaje:id,origen_direccion,destino_direccion'])
            ->when($request->estado, function ($query) {
                return $query->where('estado', $request->estado);
            })
            ->when($request->prioridad, function ($query) {
                return $query->where('prioridad', $request->prioridad);
            })
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $tickets,
        ], 200);
    }

    /**
     * Ver detalles de un ticket
     */
    public function show(Request $request, SoporteTicket $ticket): JsonResponse
    {
        $user = $request->user();

        // Verificar autorización
        if ($user->tipo_usuario === 'pasajero' || $user->tipo_usuario === 'conductor') {
            if ($ticket->usuario_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'No autorizado',
                ], 403);
            }
        } elseif (!in_array($user->tipo_usuario, ['admin', 'soporte'])) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        $ticket->load([
            'usuario:id,name,email,telefono,foto_perfil_url',
            'viaje:id,origen_direccion,destino_direccion,hora_solicitud',
            'respuestas' => function ($query) {
                return $query->orderBy('created_at', 'asc');
            },
        ]);

        return response()->json([
            'success' => true,
            'data' => $ticket,
        ], 200);
    }

    /**
     * Crear nuevo ticket de soporte
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!in_array($user->tipo_usuario, ['pasajero', 'conductor'])) {
            return response()->json([
                'success' => false,
                'message' => 'Solo pasajeros y conductores pueden crear tickets',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'asunto' => 'required|string|max:255',
            'descripcion' => 'required|string|min:10|max:2000',
            'categoria' => 'required|in:viaje,pago,conductor,pasajero,vehiculo,app,otro',
            'prioridad' => 'sometimes|in:baja,media,alta,critica',
            'viaje_id' => 'sometimes|exists:viajes,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        // Si está relacionado con un viaje, verificar que el usuario esté involucrado
        if ($request->viaje_id) {
            $viaje = Viaje::find($request->viaje_id);
            $conductorId = $user->conductor ? $user->conductor->id : null;
            if ($viaje->pasajero_id !== $user->id && $viaje->conductor_id !== $conductorId) {
                return response()->json([
                    'success' => false,
                    'message' => 'No puedes crear un ticket para este viaje',
                ], 403);
            }
        }

        try {
            $numero_ticket = 'TKT-' . strtoupper(substr(uniqid(), -8));

            $ticket = SoporteTicket::create([
                'numero_ticket' => $numero_ticket,
                'usuario_id' => $user->id,
                'viaje_id' => $request->viaje_id,
                'asunto' => $request->asunto,
                'descripcion' => $request->descripcion,
                'categoria' => $request->categoria,
                'prioridad' => $request->prioridad ?? 'media',
                'estado' => 'abierto',
            ]);

            // Registrar en logs
            DB::table('logs_sistema')->insert([
                'usuario_id' => $user->id,
                'tipo_evento' => 'otro',
                'modulo' => 'soporte',
                'accion' => 'crear_ticket_soporte',
                'descripcion' => "Ticket {$numero_ticket} creado en categoría {$request->categoria}",
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'estado' => 'info',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Ticket creado exitosamente',
                'data' => $ticket,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al crear ticket: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Responder a un ticket
     */
    public function responder(Request $request, SoporteTicket $ticket): JsonResponse
    {
        $user = $request->user();

        // Solo soporte/admin puede responder; usuario puede comentar
        $es_respuesta_staff = in_array($user->tipo_usuario, ['admin', 'soporte']);

        if ($ticket->estado === 'cerrado') {
            return response()->json([
                'success' => false,
                'message' => 'No se puede responder un ticket cerrado',
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'mensaje' => 'required|string|min:3|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // Crear respuesta/comentario
            $respuesta = DB::table('soporte_respuestas')->insertGetId([
                'ticket_id' => $ticket->id,
                'usuario_id' => $user->id,
                'mensaje' => $request->mensaje,
                'es_respuesta_staff' => $es_respuesta_staff,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Si es respuesta de staff, actualizar ticket
            if ($es_respuesta_staff) {
                $ticket->update([
                    'ultima_respuesta_staff' => now(),
                    'estado' => $request->estado ?? $ticket->estado,
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Respuesta agregada exitosamente',
                'data' => [
                    'respuesta_id' => $respuesta,
                    'mensaje' => $request->mensaje,
                    'fecha' => now(),
                    'usuario_tipo' => $es_respuesta_staff ? 'staff' : $user->tipo_usuario,
                ],
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al agregar respuesta: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Actualizar estado del ticket
     */
    public function actualizarEstado(Request $request, SoporteTicket $ticket): JsonResponse
    {
        $user = $request->user();

        if (!in_array($user->tipo_usuario, ['admin', 'soporte'])) {
            return response()->json([
                'success' => false,
                'message' => 'Solo staff puede cambiar estado de tickets',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'estado' => 'required|in:abierto,en_progreso,esperando_usuario,resuelto,cerrado',
            'notas_cierre' => 'sometimes|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $estado_anterior = $ticket->estado;

            $updates = [
                'estado' => $request->estado,
                'actualizado_por' => $user->id,
            ];

            if ($request->estado === 'cerrado') {
                $updates['fecha_cierre'] = now();
                $updates['notas_cierre'] = $request->notas_cierre;
            }

            $ticket->update($updates);

            // Registrar en logs
            DB::table('logs_sistema')->insert([
                'usuario_id' => $user->id,
                'tipo_evento' => 'otro',
                'modulo' => 'soporte',
                'accion' => 'cambio_estado_ticket',
                'descripcion' => "Ticket {$ticket->numero_ticket} cambió de {$estado_anterior} a {$request->estado}",
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'estado' => 'info',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Estado actualizado exitosamente',
                'data' => $ticket,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar estado: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener estadísticas de soporte
     */
    public function estadisticas(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!in_array($user->tipo_usuario, ['admin', 'soporte'])) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        $stats = [
            'total_tickets' => SoporteTicket::count(),
            'tickets_abiertos' => SoporteTicket::where('estado', 'abierto')->count(),
            'tickets_en_progreso' => SoporteTicket::where('estado', 'en_progreso')->count(),
            'tickets_resueltos' => SoporteTicket::where('estado', 'resuelto')->count(),
            'tickets_cerrados' => SoporteTicket::where('estado', 'cerrado')->count(),
            'por_prioridad' => [
                'critica' => SoporteTicket::where('prioridad', 'critica')->count(),
                'alta' => SoporteTicket::where('prioridad', 'alta')->count(),
                'media' => SoporteTicket::where('prioridad', 'media')->count(),
                'baja' => SoporteTicket::where('prioridad', 'baja')->count(),
            ],
            'por_categoria' => SoporteTicket::groupBy('categoria')
                ->select('categoria', DB::raw('count(*) as total'))
                ->pluck('total', 'categoria')
                ->toArray(),
            'tiempo_promedio_resolucion' => $this->calcularTiempoPromedioResolucion(),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ], 200);
    }

    /**
     * Asignar ticket a un agente de soporte
     */
    public function asignar(Request $request, SoporteTicket $ticket): JsonResponse
    {
        $user = $request->user();

        if ($user->tipo_usuario !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Solo administradores pueden asignar tickets',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'agente_id' => 'required|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $ticket->update([
                'asignado_a' => $request->agente_id,
                'estado' => 'en_progreso',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Ticket asignado exitosamente',
                'data' => $ticket,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al asignar ticket: ' . $e->getMessage(),
            ], 500);
        }
    }

    // Método auxiliar privado

    private function calcularTiempoPromedioResolucion(): string
    {
        $tickets = SoporteTicket::where('estado', 'cerrado')
            ->whereBetween('created_at', [now()->subMonth(), now()])
            ->get();

        if ($tickets->isEmpty()) {
            return 'Sin datos';
        }

        $total_horas = 0;
        foreach ($tickets as $ticket) {
            $total_horas += $ticket->fecha_cierre->diffInHours($ticket->created_at);
        }

        $promedio_horas = round($total_horas / $tickets->count(), 2);

        return $promedio_horas . ' horas';
    }
}
