<?php

namespace Database\Seeders;

use App\Models\Conductor;
use App\Models\Wallet;
use Illuminate\Database\Seeder;

class WalletSeeder extends Seeder
{
    public function run(): void
    {
        // Crear billetera para cada conductor
        $conductores = Conductor::all();

        foreach ($conductores as $conductor) {
            // Verificar si ya tiene billetera
            if (!$conductor->wallet) {
                Wallet::create([
                    'conductor_id' => $conductor->id,
                    'balance' => 50000, // Saldo inicial de 50,000 COP
                    'status' => 'active',
                    'limite_negativo' => -5000,
                ]);
            }
        }
    }
}
