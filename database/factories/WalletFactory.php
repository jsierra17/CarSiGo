<?php

namespace Database\Factories;

use App\Models\Conductor;
use App\Models\Wallet;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Wallet>
 */
class WalletFactory extends Factory
{
    protected $model = Wallet::class;

    public function definition(): array
    {
        return [
            'conductor_id' => Conductor::factory(),
            'balance' => 0,
            'status' => 'active',
            'limite_negativo' => -5000,
        ];
    }
}
