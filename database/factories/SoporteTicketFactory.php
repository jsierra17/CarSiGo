<?php

namespace Database\Factories;

use App\Models\SoporteTicket;
use App\Models\User;
use App\Models\Viaje;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\SoporteTicket>
 */
class SoporteTicketFactory extends Factory
{
    protected $model = SoporteTicket::class;

    public function definition(): array
    {
        return [
            'usuario_id' => User::factory()->state([
                'tipo_usuario' => 'pasajero',
                'estado_cuenta' => 'activa',
            ]),
            'viaje_id' => null,
            'numero_ticket' => 'TKT-' . strtoupper(fake()->unique()->bothify('########')),
            'asunto' => fake()->sentence(6),
            'descripcion' => fake()->paragraph(),
            'categoria' => 'otro',
            'prioridad' => 'media',
            'estado' => 'abierto',
        ];
    }

    public function conViaje(Viaje $viaje): static
    {
        return $this->state(fn () => [
            'viaje_id' => $viaje->id,
        ]);
    }
}
