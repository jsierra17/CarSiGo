<?php

namespace Database\Factories;

use App\Models\Conductor;
use App\Models\User;
use App\Models\Viaje;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Viaje>
 */
class ViajeFactory extends Factory
{
    protected $model = Viaje::class;

    public function definition(): array
    {
        return [
            'pasajero_id' => User::factory()->state([
                'tipo_usuario' => 'pasajero',
                'estado_cuenta' => 'activa',
            ]),
            'conductor_id' => null,
            'origen_latitud' => 9.7170,
            'origen_longitud' => -75.1210,
            'origen_direccion' => fake()->streetAddress(),
            'origen_lugar' => null,
            'destino_latitud' => 9.7180,
            'destino_longitud' => -75.1220,
            'destino_direccion' => fake()->streetAddress(),
            'destino_lugar' => null,
            'tipo' => 'estandar',
            'pasajeros_solicitados' => 1,
            'distancia_estimada' => null,
            'duracion_estimada' => null,
            'tarifa_base' => 2500,
            'precio_total' => null,
            'estado' => 'solicitado',
            'hora_solicitud' => now(),
        ];
    }

    public function asignado(Conductor $conductor): static
    {
        return $this->state(fn () => [
            'conductor_id' => $conductor->id,
            'estado' => 'asignado',
            'hora_asignacion' => now(),
        ]);
    }

    public function completado(Conductor $conductor): static
    {
        return $this->state(fn () => [
            'conductor_id' => $conductor->id,
            'estado' => 'completado',
            'hora_asignacion' => now()->subMinutes(15),
            'hora_inicio' => now()->subMinutes(12),
            'hora_finalizacion' => now()->subMinutes(1),
            'distancia_estimada' => 3.5,
            'duracion_estimada' => 900,
            'precio_total' => 10000,
        ]);
    }
}
