<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChatMessage;
use App\Models\Viaje;
use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    private NotificationService $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Obtener mensajes de un viaje
     */
    public function obtenerMensajesViaje(Request $request, Viaje $viaje): JsonResponse
    {
        $user = Auth::user();

        // Verificar que el usuario sea parte del viaje
        if ($viaje->pasajero_id !== $user->id && $viaje->conductor_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'No tienes permiso para ver los mensajes de este viaje',
            ], 403);
        }

        $mensajes = ChatMessage::where('viaje_id', $viaje->id)
            ->where(function ($query) use ($user) {
                $query->where('remitente_id', $user->id)
                      ->orWhere('destinatario_id', $user->id);
            })
            ->where(function ($query) use ($user) {
                $query->where('eliminado_por_remitente', false)
                      ->orWhere('remitente_id', '!=', $user->id);
            })
            ->where(function ($query) use ($user) {
                $query->where('eliminado_por_destinatario', false)
                      ->orWhere('destinatario_id', '!=', $user->id);
            })
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'mensajes' => $mensajes->map(function ($mensaje) {
                return [
                    'id' => $mensaje->id,
                    'viaje_id' => $mensaje->viaje_id,
                    'remitente_id' => $mensaje->remitente_id,
                    'destinatario_id' => $mensaje->destinatario_id,
                    'contenido' => $mensaje->contenido,
                    'tipo' => $mensaje->tipo,
                    'metadata' => $mensaje->metadata,
                    'leido_en' => $mensaje->leido_en,
                    'created_at' => $mensaje->created_at->toISOString(),
                    'remitente' => [
                        'id' => $mensaje->remitente->id,
                        'name' => $mensaje->remitente->name,
                        'foto_perfil_url' => $mensaje->remitente->foto_perfil_url,
                        'tipo_usuario' => $mensaje->remitente->tipo_usuario,
                    ],
                    'es mio' => $mensaje->remitente_id === Auth::id(),
                    'leido' => $mensaje->estaLeido(),
                ];
            }),
        ]);
    }

    /**
     * Enviar mensaje
     */
    public function enviarMensaje(Request $request, Viaje $viaje): JsonResponse
    {
        $user = Auth::user();

        // Validar que el viaje esté en estado adecuado para chat
        if (!in_array($viaje->estado, ['asignado', 'en_progreso'])) {
            return response()->json([
                'success' => false,
                'message' => 'El chat no está disponible para este viaje',
            ], 400);
        }

        // Determinar destinatario
        $destinatarioId = $user->id === $viaje->pasajero_id 
            ? $viaje->conductor_id 
            : $viaje->pasajero_id;

        if (!$destinatarioId) {
            return response()->json([
                'success' => false,
                'message' => 'No se puede determinar el destinatario',
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'contenido' => 'required_without:tipo|string|max:1000',
            'tipo' => 'required_without:contenido|in:texto,imagen,ubicacion,sistema',
            'metadata' => 'array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Datos inválidos',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $mensaje = ChatMessage::create([
                'viaje_id' => $viaje->id,
                'remitente_id' => $user->id,
                'destinatario_id' => $destinatarioId,
                'contenido' => $request->contenido ?? '',
                'tipo' => $request->tipo ?? 'texto',
                'metadata' => $request->metadata ?? [],
            ]);

            // Enviar notificación en tiempo real
            $this->notificationService->enviarMensajeChat($mensaje, $user);

            return response()->json([
                'success' => true,
                'message' => 'Mensaje enviado exitosamente',
                'mensaje' => [
                    'id' => $mensaje->id,
                    'viaje_id' => $mensaje->viaje_id,
                    'remitente_id' => $mensaje->remitente_id,
                    'destinatario_id' => $mensaje->destinatario_id,
                    'contenido' => $mensaje->contenido,
                    'tipo' => $mensaje->tipo,
                    'metadata' => $mensaje->metadata,
                    'leido_en' => $mensaje->leido_en,
                    'created_at' => $mensaje->created_at->toISOString(),
                    'remitente' => [
                        'id' => $mensaje->remitente->id,
                        'name' => $mensaje->remitente->name,
                        'foto_perfil_url' => $mensaje->remitente->foto_perfil_url,
                        'tipo_usuario' => $mensaje->remitente->tipo_usuario,
                    ],
                    'es mio' => true,
                    'leido' => $mensaje->estaLeido(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al enviar mensaje: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Marcar mensajes como leídos
     */
    public function marcarComoLeidos(Request $request, Viaje $viaje): JsonResponse
    {
        $user = Auth::user();

        // Verificar que el usuario sea parte del viaje
        if ($viaje->pasajero_id !== $user->id && $viaje->conductor_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'No tienes permiso para realizar esta acción',
            ], 403);
        }

        try {
            $mensajesNoLeidos = ChatMessage::where('viaje_id', $viaje->id)
                ->where('destinatario_id', $user->id)
                ->whereNull('leido_en')
                ->update(['leido_en' => now()]);

            return response()->json([
                'success' => true,
                'message' => 'Mensajes marcados como leídos',
                'mensajes_actualizados' => $mensajesNoLeidos,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al marcar mensajes como leídos: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener conversaciones del usuario
     */
    public function obtenerConversaciones(Request $request): JsonResponse
    {
        $user = Auth::user();

        // Obtener últimos mensajes de cada conversación
        $conversaciones = ChatMessage::where(function ($query) use ($user) {
            $query->where('remitente_id', $user->id)
                  ->orWhere('destinatario_id', $user->id);
        })
        ->where(function ($query) use ($user) {
            $query->where('eliminado_por_remitente', false)
                  ->orWhere('remitente_id', '!=', $user->id);
        })
        ->where(function ($query) use ($user) {
            $query->where('eliminado_por_destinatario', false)
                  ->orWhere('destinatario_id', '!=', $user->id);
        })
        ->with(['viaje', 'remitente', 'destinatario'])
        ->orderBy('created_at', 'desc')
        ->get()
        ->groupBy('viaje_id');

        $conversacionesFormat = $conversaciones->map(function ($mensajes) use ($user) {
            $ultimoMensaje = $mensajes->first();
            $viaje = $ultimoMensaje->viaje;
            $otroUsuario = $ultimoMensaje->remitente_id === $user->id 
                ? $ultimoMensaje->destinatario 
                : $ultimoMensaje->remitente;

            return [
                'viaje_id' => $viaje->id,
                'viaje_estado' => $viaje->estado,
                'otro_usuario' => [
                    'id' => $otroUsuario->id,
                    'name' => $otroUsuario->name,
                    'foto_perfil_url' => $otroUsuario->foto_perfil_url,
                    'tipo_usuario' => $otroUsuario->tipo_usuario,
                ],
                'ultimo_mensaje' => [
                    'id' => $ultimoMensaje->id,
                    'contenido' => $ultimoMensaje->contenido,
                    'tipo' => $ultimoMensaje->tipo,
                    'created_at' => $ultimoMensaje->created_at->toISOString(),
                    'leido' => $ultimoMensaje->estaLeido(),
                    'es mio' => $ultimoMensaje->remitente_id === $user->id,
                ],
                'no_leidos_count' => ChatMessage::noLeidosCount($user->id),
            ];
        });

        return response()->json([
            'success' => true,
            'conversaciones' => $conversacionesFormat->values(),
        ]);
    }

    /**
     * Eliminar mensaje
     */
    public function eliminarMensaje(Request $request, ChatMessage $mensaje): JsonResponse
    {
        $user = Auth::user();

        // Verificar que el mensaje pertenezca al usuario
        if ($mensaje->remitente_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'No puedes eliminar este mensaje',
            ], 403);
        }

        try {
            if ($mensaje->remitente_id === $user->id) {
                $mensaje->update(['eliminado_por_remitente' => true]);
            } else {
                $mensaje->update(['eliminado_por_destinatario' => true]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Mensaje eliminado exitosamente',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al eliminar mensaje: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener contador de mensajes no leídos
     */
    public function obtenerNoLeidosCount(Request $request): JsonResponse
    {
        $user = Auth::user();
        $noLeidosCount = ChatMessage::noLeidosCount($user->id);

        return response()->json([
            'success' => true,
            'no_leidos_count' => $noLeidosCount,
        ]);
    }
}
