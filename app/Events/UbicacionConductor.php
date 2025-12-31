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

class UbicacionConductor implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $viaje;
    public $conductor;
    public $ubicacion;

    /**
     * Create a new event instance.
     */
    public function __construct(Viaje $viaje, User $conductor, array $ubicacion)
    {
        $this->viaje = $viaje;
        $this->conductor = $conductor;
        $this->ubicacion = $ubicacion;
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
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'ubicacion.conductor';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'viaje_id' => $this->viaje->id,
            'conductor_id' => $this->conductor->id,
            'ubicacion' => [
                'latitud' => $this->ubicacion['latitud'],
                'longitud' => $this->ubicacion['longitud'],
                'direccion' => $this->ubicacion['direccion'] ?? null,
                'velocidad' => $this->ubicacion['velocidad'] ?? null,
                'rumbo' => $this->ubicacion['rumbo'] ?? null,
            ],
            'timestamp' => now()->toISOString(),
        ];
    }
}
