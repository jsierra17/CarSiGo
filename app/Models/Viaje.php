<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Viaje extends Model
{
    use SoftDeletes;

    protected $table = 'viajes';

    protected $fillable = [
        'pasajero_id',
        'conductor_id',
        'origen_latitud',
        'origen_longitud',
        'origen_direccion',
        'origen_lugar',
        'destino_latitud',
        'destino_longitud',
        'destino_direccion',
        'destino_lugar',
        'tipo',
        'pasajeros_solicitados',
        'distancia_estimada',
        'duracion_estimada',
        'tarifa_base',
        'precio_total',
        'estado',
        'hora_solicitud',
        'hora_asignacion',
        'hora_inicio',
        'hora_finalizacion',
        'calificacion_pasajero',
        'calificacion_conductor',
        'comentario_pasajero',
        'comentario_conductor',
        'notas_especiales',
        'incidentes',
        'requiere_factura',
        'razon_cancelacion',
        'cancelado_por',
    ];

    protected $casts = [
        'origen_latitud' => 'decimal:8',
        'origen_longitud' => 'decimal:8',
        'destino_latitud' => 'decimal:8',
        'destino_longitud' => 'decimal:8',
        'distancia_estimada' => 'decimal:2',
        'tarifa_base' => 'decimal:2',
        'precio_total' => 'decimal:2',
        'hora_solicitud' => 'datetime',
        'hora_asignacion' => 'datetime',
        'hora_inicio' => 'datetime',
        'hora_finalizacion' => 'datetime',
        'requiere_factura' => 'boolean',
    ];

    // Relaciones
    public function pasajero(): BelongsTo
    {
        return $this->belongsTo(User::class, 'pasajero_id');
    }

    public function conductor(): BelongsTo
    {
        return $this->belongsTo(Conductor::class, 'conductor_id');
    }

    public function ubicaciones(): HasMany
    {
        return $this->hasMany(Ubicacion::class, 'viaje_id');
    }

    public function pago(): BelongsTo
    {
        return $this->belongsTo(Pago::class);
    }

    public function emergencia(): HasMany
    {
        return $this->hasMany(Emergencia::class, 'viaje_id');
    }

    public function tickets_soporte(): HasMany
    {
        return $this->hasMany(SoporteTicket::class, 'viaje_id');
    }
}
