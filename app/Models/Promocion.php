<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Promocion extends Model
{
    use SoftDeletes;

    protected $table = 'promociones';

    protected $fillable = [
        'codigo',
        'nombre',
        'descripcion',
        'tipo',
        'valor',
        'valor_minimo_viaje',
        'usos_maximos',
        'usos_por_usuario',
        'fecha_inicio',
        'fecha_vencimiento',
        'activa',
        'aplica_a',
        'ciudad_aplicable',
        'veces_usado',
        'presupuesto_total',
        'gasto_total',
        'terminos_condiciones',
        'requiere_codigo_referencia',
        'codigo_referencia_requerido',
        'creada_por',
    ];

    protected $casts = [
        'valor' => 'decimal:2',
        'valor_minimo_viaje' => 'decimal:2',
        'fecha_inicio' => 'datetime',
        'fecha_vencimiento' => 'datetime',
        'activa' => 'boolean',
        'requiere_codigo_referencia' => 'boolean',
        'gasto_total' => 'decimal:2',
    ];

    // Relaciones
    public function creador(): BelongsTo
    {
        return $this->belongsTo(User::class, 'creada_por');
    }
}
