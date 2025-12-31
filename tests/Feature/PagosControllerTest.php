<?php

namespace Tests\Feature;

use App\Models\Conductor;
use App\Models\Pago;
use App\Models\User;
use App\Models\Viaje;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class PagosControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_cannot_process_payment_for_non_completed_trip(): void
    {
        $conductor = Conductor::factory()->create(['estado' => 'activo']);
        Wallet::factory()->create(['conductor_id' => $conductor->id]);
        $viaje = Viaje::factory()->asignado($conductor)->create(['estado' => 'en_progreso']);

        Sanctum::actingAs($conductor->usuario);

        $this->postJson("/api/pagos/viajes/{$viaje->id}/procesar", [
            'metodo_pago' => 'efectivo',
        ])->assertStatus(400);
    }

    public function test_cannot_process_payment_twice_for_same_trip(): void
    {
        $conductor = Conductor::factory()->create(['estado' => 'activo']);
        Wallet::factory()->create(['conductor_id' => $conductor->id]);
        $viaje = Viaje::factory()->completado($conductor)->create();

        Sanctum::actingAs($conductor->usuario);

        $first = $this->postJson("/api/pagos/viajes/{$viaje->id}/procesar", [
            'metodo_pago' => 'efectivo',
            'comision_porcentaje' => 10,
        ]);
        $first->assertStatus(201);

        $second = $this->postJson("/api/pagos/viajes/{$viaje->id}/procesar", [
            'metodo_pago' => 'efectivo',
            'comision_porcentaje' => 10,
        ]);
        $second->assertStatus(400);
    }

    public function test_reembolso_only_admin(): void
    {
        $admin = User::factory()->create(['tipo_usuario' => 'admin', 'estado_cuenta' => 'activa']);
        $conductor = Conductor::factory()->create(['estado' => 'activo']);
        $pasajero = User::factory()->create(['tipo_usuario' => 'pasajero', 'estado_cuenta' => 'activa']);
        $viaje = Viaje::factory()->completado($conductor)->create(['pasajero_id' => $pasajero->id]);

        $pago = Pago::create([
            'viaje_id' => $viaje->id,
            'pasajero_id' => $pasajero->id,
            'conductor_id' => $conductor->id,
            'monto_subtotal' => 10000,
            'impuesto' => 0,
            'descuento' => 0,
            'monto_total' => 10000,
            'comision_plataforma' => 1000,
            'monto_conductor' => 9000,
            'metodo_pago' => 'efectivo',
            'estado' => 'completado',
            'numero_transaccion' => 'TRX-TEST-1',
            'fecha_solicitud' => now(),
            'fecha_procesamiento' => now(),
            'fecha_completacion' => now(),
            'requiere_comprobante' => false,
        ]);

        Sanctum::actingAs($conductor->usuario);
        $this->postJson("/api/pagos/{$pago->id}/reembolsar", ['razon' => 'test'])->assertStatus(403);

        Sanctum::actingAs($admin);
        $this->postJson("/api/pagos/{$pago->id}/reembolsar", ['razon' => 'test'])->assertStatus(200);
    }
}
