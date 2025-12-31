<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Pago extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'pagos';

    protected $fillable = [
        'viaje_id',
        'pasajero_id',
        'conductor_id',
        'monto_subtotal',
        'impuesto',
        'descuento',
        'monto_total',
        'comision_plataforma',
        'monto_conductor',
        'metodo_pago',
        'estado',
        'numero_transaccion',
        'referencia_proveedor',
        'respuesta_proveedor',
        'fecha_solicitud',
        'fecha_procesamiento',
        'fecha_completacion',
        'notas',
        'requiere_comprobante',
    ];

    protected $casts = [
        'monto_subtotal' => 'decimal:2',
        'impuesto' => 'decimal:2',
        'descuento' => 'decimal:2',
        'monto_total' => 'decimal:2',
        'comision_plataforma' => 'decimal:2',
        'monto_conductor' => 'decimal:2',
        'fecha_solicitud' => 'datetime',
        'fecha_procesamiento' => 'datetime',
        'fecha_completacion' => 'datetime',
        'requiere_comprobante' => 'boolean',
    ];

    // Relaciones
    public function viaje(): BelongsTo
    {
        return $this->belongsTo(Viaje::class, 'viaje_id');
    }

    public function pasajero(): BelongsTo
    {
        return $this->belongsTo(User::class, 'pasajero_id');
    }

    public function conductor(): BelongsTo
    {
        return $this->belongsTo(Conductor::class, 'conductor_id');
    }

    public function comision(): HasMany
    {
        return $this->hasMany(Comision::class, 'pago_id');
    }
}
