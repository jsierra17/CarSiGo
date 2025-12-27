<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'wallet_id',
        'type',
        'amount',
        'description',
        'reference',
        'status',
    ];

    protected $casts = [
        'amount' => 'float',
    ];

    // Relaciones
    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }

    public function viaje()
    {
        return $this->belongsTo(Viaje::class, 'reference', 'id');
    }
}
