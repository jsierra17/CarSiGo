<?php

namespace Tests\Feature;

use App\Models\Conductor;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Viaje;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CashCommissionTest extends TestCase
{
    use RefreshDatabase;

    public function test_wallet_commission_is_applied_only_for_cash_payments(): void
    {
        $conductor = Conductor::factory()->create();
        $wallet = Wallet::factory()->create([
            'conductor_id' => $conductor->id,
            'balance' => 0,
            'status' => 'active',
            'limite_negativo' => -5000,
        ]);

        $pasajero = User::factory()->create([
            'tipo_usuario' => 'pasajero',
            'estado_cuenta' => 'activa',
        ]);

        $viaje = Viaje::factory()->completado($conductor)->create([
            'pasajero_id' => $pasajero->id,
        ]);

        Sanctum::actingAs($conductor->usuario);

        $noCash = $this->postJson("/api/pagos/viajes/{$viaje->id}/procesar", [
            'metodo_pago' => 'nequi',
            'comision_porcentaje' => 10,
        ]);

        $noCash->assertStatus(201);
        $this->assertDatabaseCount('transactions', 0);

        // Nuevo viaje para pago en efectivo
        $viaje2 = Viaje::factory()->completado($conductor)->create();

        $cash = $this->postJson("/api/pagos/viajes/{$viaje2->id}/procesar", [
            'metodo_pago' => 'efectivo',
            'comision_porcentaje' => 10,
        ]);

        $cash->assertStatus(201);

        $this->assertDatabaseHas('transactions', [
            'wallet_id' => $wallet->id,
            'type' => 'debit',
            'status' => 'completed',
        ]);

        $wallet->refresh();
        $this->assertLessThanOrEqual(0, (float) $wallet->balance);

        $tx = Transaction::where('wallet_id', $wallet->id)->first();
        $this->assertNotNull($tx);
    }
}
