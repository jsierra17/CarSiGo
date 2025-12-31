<?php

namespace App\Services;

use App\Models\User;
use App\Models\Viaje;
use App\Models\ChatMessage;
use App\Events\ViajeSolicitado;
use App\Events\ViajeAsignado;
use App\Events\ViajeEnProgreso;
use App\Events\ViajeCompletado;
use App\Events\MensajeChat;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    private $messaging;

    public function __construct()
    {
        $firebase = (new Factory)
            ->withServiceAccount([
                'type' => 'service_account',
                'project_id' => env('FIREBASE_PROJECT_ID'),
                'private_key_id' => env('FIREBASE_PRIVATE_KEY_ID'),
                'private_key' => str_replace('\\n', "\n", env('FIREBASE_PRIVATE_KEY')),
                'client_email' => env('FIREBASE_CLIENT_EMAIL'),
                'client_id' => env('FIREBASE_CLIENT_ID'),
                'auth_uri' => env('FIREBASE_AUTH_URI'),
                'token_uri' => env('FIREBASE_TOKEN_URI'),
            ]);

        $this->messaging = $firebase->createMessaging();
    }

    /**
     * Notificar nuevo viaje solicitado a conductores disponibles
     */
    public function notificarViajeSolicitado(Viaje $viaje, User $pasajero): void
    {
        // Evento WebSocket para conductores conectados
        broadcast(new ViajeSolicitado($viaje, $pasajero));

        // Notificación push a conductores disponibles
        $conductoresDisponibles = User::where('tipo_usuario', 'conductor')
            ->where('estado_cuenta', 'activa')
            ->whereNotNull('device_token')
            ->get();

        foreach ($conductoresDisponibles as $conductor) {
            $this->enviarNotificacionPush(
                $conductor,
                'Nuevo Viaje Solicitado',
                "Pasajero {$pasajero->name} solicita viaje a {$viaje->destino_direccion}",
                [
                    'type' => 'viaje_solicitado',
                    'viaje_id' => $viaje->id,
                    'pasajero_id' => $pasajero->id,
                    'origen' => $viaje->origen_direccion,
                    'destino' => $viaje->destino_direccion,
                    'precio' => $viaje->precio_total,
                ]
            );
        }
    }

    /**
     * Notificar viaje asignado al pasajero
     */
    public function notificarViajeAsignado(Viaje $viaje, User $conductor): void
    {
        $pasajero = $viaje->pasajero;

        // Evento WebSocket
        broadcast(new ViajeAsignado($viaje, $conductor));

        // Notificación push al pasajero
        if ($pasajero->device_token) {
            $this->enviarNotificacionPush(
                $pasajero,
                'Conductor Asignado',
                "{$conductor->name} ha aceptado tu viaje",
                [
                    'type' => 'viaje_asignado',
                    'viaje_id' => $viaje->id,
                    'conductor_id' => $conductor->id,
                    'conductor_nombre' => $conductor->name,
                    'conductor_foto' => $conductor->foto_perfil_url,
                    'conductor_telefono' => $conductor->telefono,
                ]
            );
        }
    }

    /**
     * Notificar viaje en progreso
     */
    public function notificarViajeEnProgreso(Viaje $viaje, User $conductor): void
    {
        $pasajero = $viaje->pasajero;

        // Evento WebSocket
        broadcast(new ViajeEnProgreso($viaje, $conductor));

        // Notificación push al pasajero
        if ($pasajero->device_token) {
            $this->enviarNotificacionPush(
                $pasajero,
                'Viaje en Progreso',
                "Tu viaje ha comenzado. {$conductor->name} está en camino.",
                [
                    'type' => 'viaje_en_progreso',
                    'viaje_id' => $viaje->id,
                    'conductor_id' => $conductor->id,
                ]
            );
        }
    }

    /**
     * Notificar viaje completado
     */
    public function notificarViajeCompletado(Viaje $viaje, User $conductor): void
    {
        $pasajero = $viaje->pasajero;

        // Evento WebSocket
        broadcast(new ViajeCompletado($viaje, $conductor));

        // Notificación push al pasajero
        if ($pasajero->device_token) {
            $this->enviarNotificacionPush(
                $pasajero,
                'Viaje Completado',
                "Tu viaje ha finalizado. Califica a {$conductor->name}",
                [
                    'type' => 'viaje_completado',
                    'viaje_id' => $viaje->id,
                    'conductor_id' => $conductor->id,
                    'precio' => $viaje->precio_total,
                ]
            );
        }

        // Notificación push al conductor
        if ($conductor->device_token) {
            $this->enviarNotificacionPush(
                $conductor,
                'Viaje Completado',
                "Has completado el viaje. Califica al pasajero.",
                [
                    'type' => 'viaje_completado',
                    'viaje_id' => $viaje->id,
                    'pasajero_id' => $pasajero->id,
                    'precio' => $viaje->precio_total,
                ]
            );
        }
    }

    /**
     * Enviar mensaje de chat
     */
    public function enviarMensajeChat(ChatMessage $mensaje, User $remitente): void
    {
        // Evento WebSocket
        broadcast(new MensajeChat($mensaje, $remitente));

        // Notificación push al destinatario si está offline
        $destinatario = $mensaje->destinatario;
        
        if ($destinatario->device_token && !$this->usuarioEstaOnline($destinatario->id)) {
            $nombreRemitente = $remitente->name;
            $tipoMensaje = $this->getTipoMensajeLabel($mensaje->tipo);

            $this->enviarNotificacionPush(
                $destinatario,
                "Nuevo mensaje de {$nombreRemitente}",
                $this->generarPreviewMensaje($mensaje),
                [
                    'type' => 'chat_mensaje',
                    'mensaje_id' => $mensaje->id,
                    'viaje_id' => $mensaje->viaje_id,
                    'remitente_id' => $remitente->id,
                    'remitente_nombre' => $nombreRemitente,
                    'tipo_mensaje' => $mensaje->tipo,
                ]
            );
        }
    }

    /**
     * Enviar notificación push
     */
    private function enviarNotificacionPush(User $usuario, string $titulo, string $cuerpo, array $datos = []): void
    {
        if (!$usuario->device_token) {
            return;
        }

        try {
            $message = CloudMessage::withTarget($usuario->device_token)
                ->withNotification(Notification::create($titulo, $cuerpo))
                ->withData($datos);

            $this->messaging->send($message);

            Log::info('Notificación push enviada', [
                'user_id' => $usuario->id,
                'title' => $titulo,
                'data' => $datos,
            ]);
        } catch (\Exception $e) {
            Log::error('Error enviando notificación push', [
                'user_id' => $usuario->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Verificar si usuario está online
     */
    private function usuarioEstaOnline(int $userId): bool
    {
        // Aquí podrías implementar lógica para verificar si el usuario está conectado
        // Por ejemplo, verificando en Redis o cache si tiene una conexión WebSocket activa
        return false; // Por ahora asumimos que está offline
    }

    /**
     * Generar preview del mensaje
     */
    private function generarPreviewMensaje(ChatMessage $mensaje): string
    {
        return match ($mensaje->tipo) {
            'texto' => substr($mensaje->contenido, 0, 50) . (strlen($mensaje->contenido) > 50 ? '...' : ''),
            'imagen' => '📷 Imagen',
            'ubicacion' => '📍 Ubicación compartida',
            'sistema' => $mensaje->contenido,
            default => 'Nuevo mensaje',
        };
    }

    /**
     * Obtener label del tipo de mensaje
     */
    private function getTipoMensajeLabel(string $tipo): string
    {
        return match ($tipo) {
            'texto' => 'mensaje de texto',
            'imagen' => 'imagen',
            'ubicacion' => 'ubicación',
            'sistema' => 'notificación del sistema',
            default => 'mensaje',
        };
    }

    /**
     * Enviar notificación masiva
     */
    public function enviarNotificacionMasiva(array $usuarios, string $titulo, string $cuerpo, array $datos = []): void
    {
        foreach ($usuarios as $usuario) {
            $this->enviarNotificacionPush($usuario, $titulo, $cuerpo, $datos);
        }
    }

    /**
     * Notificar actualización de ubicación del conductor
     */
    public function notificarActualizacionUbicacion(Viaje $viaje, User $conductor, array $ubicacion): void
    {
        $pasajero = $viaje->pasajero;

        // Solo enviar notificación WebSocket para actualizaciones de ubicación
        // No enviar push para no saturar al usuario
        broadcast(new \App\Events\UbicacionConductor($viaje, $conductor, $ubicacion));
    }
}
