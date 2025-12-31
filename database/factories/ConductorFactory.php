<?php

namespace Database\Factories;

use App\Models\Conductor;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Conductor>
 */
class ConductorFactory extends Factory
{
    protected $model = Conductor::class;

    public function definition(): array
    {
        return [
            'usuario_id' => User::factory()->state([
                'tipo_usuario' => 'conductor',
                'estado_cuenta' => 'activa',
            ]),
            'numero_licencia' => 'LIC-' . fake()->unique()->numerify('########'),
            'fecha_vencimiento_licencia' => now()->addYear()->toDateString(),
            'tipo_licencia' => 'B',
            'estado' => 'activo',
            'documentos_verificados' => true,
            'antecedentes_limpios' => true,
            'calificacion_promedio' => 5.00,
            'total_viajes' => 0,
            'total_calificaciones' => 0,
            'comision_porcentaje' => 5.00,
            'ganancias_totales' => 0,
            'saldo_pendiente' => 0,
            'estado_conexion' => 'fuera_linea',
        ];
    }
}
