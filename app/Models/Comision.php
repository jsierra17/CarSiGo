<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Comision extends Model
{
    protected $table = 'comisiones';

    protected $fillable = [
        'conductor_id',
        'pago_id',
        'monto_viaje',
        'porcentaje_comision',
        'monto_comision',
        'monto_neto_conductor',
        'fecha_comisión',
        'numero_quincena',
        'estado',
        'fecha_pago',
        'metodo_retiro',
        'deduccion_daños',
        'deduccion_multa',
        'deduccion_otra',
        'detalle_deducciones',
    ];

    protected $casts = [
        'monto_viaje' => 'decimal:2',
        'porcentaje_comision' => 'decimal:2',
        'monto_comision' => 'decimal:2',
        'monto_neto_conductor' => 'decimal:2',
        'fecha_comisión' => 'date',
        'fecha_pago' => 'datetime',
        'deduccion_daños' => 'decimal:2',
        'deduccion_multa' => 'decimal:2',
        'deduccion_otra' => 'decimal:2',
    ];

    // Relaciones
    public function conductor(): BelongsTo
    {
        return $this->belongsTo(Conductor::class, 'conductor_id');
    }

    public function pago(): BelongsTo
    {
        return $this->belongsTo(Pago::class, 'pago_id');
    }
}
