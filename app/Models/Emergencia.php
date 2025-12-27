<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Emergencia extends Model
{
    use SoftDeletes;

    protected $table = 'emergencias';

    protected $fillable = [
        'usuario_id',
        'viaje_id',
        'tipo',
        'latitud',
        'longitud',
        'direccion',
        'estado',
        'prioridad',
        'respondida_por',
        'hora_respuesta',
        'hora_resolucion',
        'descripcion_resolucion',
        'descripcion',
        'numero_contacto_emergencia',
        'requiere_policia',
        'requiere_ambulancia',
        'numero_reporte_policia',
        'notas_internas',
    ];

    protected $casts = [
        'latitud' => 'decimal:8',
        'longitud' => 'decimal:8',
        'requiere_policia' => 'boolean',
        'requiere_ambulancia' => 'boolean',
        'hora_respuesta' => 'datetime',
        'hora_resolucion' => 'datetime',
    ];

    // Relaciones
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    public function viaje(): BelongsTo
    {
        return $this->belongsTo(Viaje::class, 'viaje_id');
    }
}
