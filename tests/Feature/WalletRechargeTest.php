<?php

namespace Tests\Feature;

use App\Models\Conductor;
use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class WalletRechargeTest extends TestCase
{
    use RefreshDatabase;

    public function test_conductor_can_recharge_and_confirm_recharge_updates_balance(): void
    {
        $conductor = Conductor::factory()->create();
        $wallet = Wallet::factory()->create([
            'conductor_id' => $conductor->id,
            'balance' => 0,
            'status' => 'active',
            'limite_negativo' => -5000,
        ]);

        Sanctum::actingAs($conductor->usuario);

        $recarga = $this->postJson('/api/wallet/recargar', [
            'monto' => 20000,
            'metodo' => 'nequi',
        ]);

        $recarga->assertStatus(201);

        $transactionId = $recarga->json('data.transaction_id');
        $this->assertNotNull($transactionId);

        $tx = Transaction::findOrFail($transactionId);
        $this->assertSame('pending', $tx->status);

        $confirmar = $this->postJson('/api/wallet/confirmar-recarga', [
            'reference' => $tx->reference,
            'status' => 'completed',
        ]);

        $confirmar->assertStatus(200);

        $wallet->refresh();
        $tx->refresh();

        $this->assertSame('completed', $tx->status);
        $this->assertEquals(20000, (float) $wallet->balance);
    }
}
