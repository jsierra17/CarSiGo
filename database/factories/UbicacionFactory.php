<?php

namespace Database\Factories;

use App\Models\Conductor;
use App\Models\Ubicacion;
use App\Models\User;
use App\Models\Viaje;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Ubicacion>
 */
class UbicacionFactory extends Factory
{
    protected $model = Ubicacion::class;

    public function definition(): array
    {
        return [
            'tipo' => 'conductor',
            'conductor_id' => Conductor::factory(),
            'pasajero_id' => null,
            'viaje_id' => null,
            'latitud' => 9.7170,
            'longitud' => -75.1210,
            'precision' => 5,
            'direccion' => null,
            'ciudad' => null,
            'departamento' => null,
            'codigo_postal' => null,
            'descripcion' => null,
            'estado' => 'activa',
            'timestamp_ubicacion' => now(),
            'proveedor' => 'gps',
            'velocidad' => null,
            'rumbo' => null,
        ];
    }

    public function pasajero(User $pasajero, ?Viaje $viaje = null): static
    {
        return $this->state(fn () => [
            'tipo' => 'pasajero_en_viaje',
            'conductor_id' => null,
            'pasajero_id' => $pasajero->id,
            'viaje_id' => $viaje?->id,
        ]);
    }
}
