<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use App\Models\ChatMessage;
use App\Models\User;

class MensajeChat implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $mensaje;
    public $remitente;
    public $viaje;

    /**
     * Create a new event instance.
     */
    public function __construct(ChatMessage $mensaje, User $remitente)
    {
        $this->mensaje = $mensaje;
        $this->remitente = $remitente;
        $this->viaje = $mensaje->viaje;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('chat.viaje.' . $this->viaje->id),
            new PrivateChannel('user.' . $this->mensaje->remitente_id),
            new PrivateChannel('user.' . $this->mensaje->destinatario_id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'chat.nuevo_mensaje';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'mensaje' => [
                'id' => $this->mensaje->id,
                'viaje_id' => $this->mensaje->viaje_id,
                'remitente_id' => $this->mensaje->remitente_id,
                'destinatario_id' => $this->mensaje->destinatario_id,
                'contenido' => $this->mensaje->contenido,
                'tipo' => $this->mensaje->tipo,
                'metadata' => $this->mensaje->metadata,
                'created_at' => $this->mensaje->created_at->toISOString(),
            ],
            'remitente' => [
                'id' => $this->remitente->id,
                'name' => $this->remitente->name,
                'foto_perfil_url' => $this->remitente->foto_perfil_url,
                'tipo_usuario' => $this->remitente->tipo_usuario,
            ],
            'timestamp' => now()->toISOString(),
        ];
    }
}
