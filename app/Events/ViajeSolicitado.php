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

class ViajeSolicitado implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $viaje;
    public $pasajero;

    /**
     * Create a new event instance.
     */
    public function __construct(Viaje $viaje, User $pasajero)
    {
        $this->viaje = $viaje;
        $this->pasajero = $pasajero;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('conductores.disponibles'),
            new PrivateChannel('viaje.' . $this->viaje->id),
            new PrivateChannel('user.' . $this->pasajero->id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'viaje.solicitado';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'viaje' => [
                'id' => $this->viaje->id,
                'pasajero_id' => $this->viaje->pasajero_id,
                'origen_direccion' => $this->viaje->origen_direccion,
                'destino_direccion' => $this->viaje->destino_direccion,
                'origen_latitud' => $this->viaje->origen_latitud,
                'origen_longitud' => $this->viaje->origen_longitud,
                'destino_latitud' => $this->viaje->destino_latitud,
                'destino_longitud' => $this->viaje->destino_longitud,
                'precio_total' => $this->viaje->precio_total,
                'distancia_km' => $this->viaje->distancia_km,
                'duracion_minutos' => $this->viaje->duracion_minutos,
                'tipo' => $this->viaje->tipo,
                'pasajeros_solicitados' => $this->viaje->pasajeros_solicitados,
                'notas_especiales' => $this->viaje->notas_especiales,
                'estado' => $this->viaje->estado,
                'created_at' => $this->viaje->created_at->toISOString(),
            ],
            'pasajero' => [
                'id' => $this->pasajero->id,
                'name' => $this->pasajero->name,
                'telefono' => $this->pasajero->telefono,
                'foto_perfil_url' => $this->pasajero->foto_perfil_url,
                'rating_promedio' => $this->pasajero->viajesComoPasajero()->avg('calificacion_pasajero') ?? 0,
            ],
            'timestamp' => now()->toISOString(),
        ];
    }
}
