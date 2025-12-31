<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use App\Models\Viaje;
use App\Models\User;

class ViajeCompletado implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $viaje;
    public $conductor;

    /**
     * Create a new event instance.
     */
    public function __construct(Viaje $viaje, User $conductor)
    {
        $this->viaje = $viaje;
        $this->conductor = $conductor;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('viaje.' . $this->viaje->id),
            new PrivateChannel('user.' . $this->viaje->pasajero_id),
            new PrivateChannel('user.' . $this->conductor->id),
            new PrivateChannel('conductores.' . $this->conductor->id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'viaje.completado';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'viaje' => [
                'id' => $this->viaje->id,
                'estado' => $this->viaje->estado,
                'fecha_finalizacion' => $this->viaje->fecha_finalizacion?->toISOString(),
                'precio_total' => $this->viaje->precio_total,
                'duracion_real' => $this->viaje->duracion_real,
                'distancia_real' => $this->viaje->distancia_real,
            ],
            'conductor' => [
                'id' => $this->conductor->id,
                'name' => $this->conductor->name,
            ],
            'timestamp' => now()->toISOString(),
        ];
    }
}
