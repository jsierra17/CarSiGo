<?php

namespace Database\Factories;

use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Transaction>
 */
class TransactionFactory extends Factory
{
    protected $model = Transaction::class;

    public function definition(): array
    {
        return [
            'wallet_id' => Wallet::factory(),
            'type' => 'credit',
            'amount' => 10000,
            'description' => 'Test transaction',
            'reference' => 'TST-' . fake()->unique()->uuid(),
            'status' => 'completed',
        ];
    }
}
