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

class ViajeAsignado implements ShouldBroadcast
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
        return 'viaje.asignado';
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
                'conductor_id' => $this->viaje->conductor_id,
                'fecha_asignacion' => $this->viaje->fecha_asignacion?->toISOString(),
            ],
            'conductor' => [
                'id' => $this->conductor->id,
                'name' => $this->conductor->name,
                'telefono' => $this->conductor->telefono,
                'foto_perfil_url' => $this->conductor->foto_perfil_url,
                'vehiculo' => $this->conductor->vehiculo,
                'rating_promedio' => $this->conductor->viajesComoConductor()->avg('calificacion_conductor') ?? 0,
            ],
            'timestamp' => now()->toISOString(),
        ];
    }
}
