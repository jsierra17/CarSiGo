<?php

namespace Database\Factories;

use App\Models\Conductor;
use App\Models\Vehiculo;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Vehiculo>
 */
class VehiculoFactory extends Factory
{
    protected $model = Vehiculo::class;

    public function definition(): array
    {
        return [
            'conductor_id' => Conductor::factory(),
            'placa' => fake()->unique()->bothify('???###'),
            'marca' => fake()->randomElement(['Toyota', 'Chevrolet', 'Kia', 'Renault']),
            'modelo' => fake()->randomElement(['Sedan', 'Hatchback', 'SUV']),
            'anio' => fake()->numberBetween(2010, (int) now()->format('Y')),
            'color' => fake()->safeColorName(),
            'categoria' => 'basico',
            'capacidad_pasajeros' => 4,
            'numero_chasis' => fake()->unique()->bothify('CHS#########'),
            'numero_motor' => fake()->unique()->bothify('MTR#########'),
            'numero_soat' => fake()->unique()->bothify('SOAT########'),
            'vencimiento_soat' => now()->addMonths(6)->toDateString(),
            'numero_tecnica_mecanica' => fake()->bothify('TM########'),
            'vencimiento_tecnica' => now()->addMonths(6)->toDateString(),
            'numero_permisoOperativo' => fake()->unique()->bothify('PO########'),
            'vencimiento_permiso' => now()->addMonths(6)->toDateString(),
            'documentos_vigentes' => true,
            'estado' => 'inactivo',
            'tiene_gps' => true,
            'tiene_boton_panico' => true,
            'tiene_camara' => false,
            'kilometraje' => 0,
        ];
    }
}
