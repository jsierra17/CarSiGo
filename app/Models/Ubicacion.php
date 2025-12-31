<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Ubicacion extends Model
{
    use HasFactory;

    protected $table = 'ubicaciones';

    protected $fillable = [
        'tipo',
        'conductor_id',
        'pasajero_id',
        'viaje_id',
        'latitud',
        'longitud',
        'precision',
        'direccion',
        'ciudad',
        'departamento',
        'codigo_postal',
        'descripcion',
        'estado',
        'timestamp_ubicacion',
        'proveedor',
        'velocidad',
        'rumbo',
    ];

    protected $casts = [
        'latitud' => 'decimal:8',
        'longitud' => 'decimal:8',
        'precision' => 'decimal:2',
        'velocidad' => 'decimal:2',
        'rumbo' => 'decimal:2',
        'timestamp_ubicacion' => 'datetime',
    ];

    // Relaciones
    public function conductor(): BelongsTo
    {
        return $this->belongsTo(Conductor::class, 'conductor_id');
    }

    public function pasajero(): BelongsTo
    {
        return $this->belongsTo(User::class, 'pasajero_id');
    }

    public function viaje(): BelongsTo
    {
        return $this->belongsTo(Viaje::class, 'viaje_id');
    }
}
