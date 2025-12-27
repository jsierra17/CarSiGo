<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Wallet extends Model
{
    use HasFactory;

    protected $fillable = [
        'conductor_id',
        'balance',
        'status',
        'limite_negativo',
    ];

    protected $casts = [
        'balance' => 'float',
        'limite_negativo' => 'float',
    ];

    // Relaciones
    public function conductor()
    {
        return $this->belongsTo(Conductor::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    // Métodos útiles
    public function puedeAceptarViajes(): bool
    {
        return $this->balance >= $this->limite_negativo && $this->status === 'active';
    }

    public function aplicarComision(float $monto, float $porcentaje, string $referencia): Transaction
    {
        $comision = $monto * ($porcentaje / 100);
        
        return $this->transactions()->create([
            'type' => 'debit',
            'amount' => $comision,
            'description' => "Comisión por viaje - {$porcentaje}%",
            'reference' => $referencia,
            'status' => 'completed',
        ]);
    }

    public function recargar(float $monto, string $metodo): Transaction
    {
        return $this->transactions()->create([
            'type' => 'credit',
            'amount' => $monto,
            'description' => "Recarga de saldo - {$metodo}",
            'reference' => 'RECARGA-' . uniqid(),
            'status' => 'completed',
        ]);
    }

    public function actualizarBalance(): float
    {
        $debits = $this->transactions()
            ->where('type', 'debit')
            ->where('status', 'completed')
            ->sum('amount');

        $credits = $this->transactions()
            ->where('type', 'credit')
            ->where('status', 'completed')
            ->sum('amount');

        $nuevoBalance = $credits - $debits;
        $this->update(['balance' => $nuevoBalance]);

        if ($nuevoBalance < $this->limite_negativo) {
            $this->update(['status' => 'blocked']);
        } elseif ($this->status === 'blocked' && $nuevoBalance >= $this->limite_negativo) {
            $this->update(['status' => 'active']);
        }

        return $nuevoBalance;
    }
}
