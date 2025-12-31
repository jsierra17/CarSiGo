<?php

namespace Database\Factories;

use App\Models\SoporteRespuesta;
use App\Models\SoporteTicket;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\SoporteRespuesta>
 */
class SoporteRespuestaFactory extends Factory
{
    protected $model = SoporteRespuesta::class;

    public function definition(): array
    {
        return [
            'ticket_id' => SoporteTicket::factory(),
            'usuario_id' => User::factory()->state([
                'tipo_usuario' => 'pasajero',
                'estado_cuenta' => 'activa',
            ]),
            'mensaje' => fake()->sentence(10),
            'es_respuesta_staff' => false,
        ];
    }
}
