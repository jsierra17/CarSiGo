<?php

namespace Tests\Feature;

use App\Models\Conductor;
use App\Models\Viaje;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class WalletBlockingTest extends TestCase
{
    use RefreshDatabase;

    public function test_conductor_cannot_accept_trip_when_wallet_balance_is_below_limit(): void
    {
        $conductor = Conductor::factory()->create();
        Wallet::factory()->create([
            'conductor_id' => $conductor->id,
            'balance' => -6000,
            'status' => 'active',
            'limite_negativo' => -5000,
        ]);

        $viaje = Viaje::factory()->create([
            'estado' => 'solicitado',
            'conductor_id' => null,
        ]);

        Sanctum::actingAs($conductor->usuario);

        $response = $this->patchJson("/api/viajes/{$viaje->id}/aceptar");

        $response->assertStatus(403);
    }
}
