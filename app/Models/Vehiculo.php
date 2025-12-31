<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Vehiculo extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'vehiculos';

    protected $fillable = [
        'conductor_id',
        'placa',
        'marca',
        'modelo',
        'anio',
        'color',
        'categoria',
        'capacidad_pasajeros',
        'numero_chasis',
        'numero_motor',
        'numero_soat',
        'vencimiento_soat',
        'numero_tecnica_mecanica',
        'vencimiento_tecnica',
        'numero_permisoOperativo',
        'vencimiento_permiso',
        'documentos_vigentes',
        'estado',
        'observaciones',
        'tiene_gps',
        'tiene_boton_panico',
        'tiene_camara',
        'proxima_revision',
        'kilometraje',
        'fecha_verificacion',
        'verificado_por',
    ];

    protected $casts = [
        'documentos_vigentes' => 'boolean',
        'tiene_gps' => 'boolean',
        'tiene_boton_panico' => 'boolean',
        'tiene_camara' => 'boolean',
        'vencimiento_soat' => 'date',
        'vencimiento_tecnica' => 'date',
        'vencimiento_permiso' => 'date',
        'proxima_revision' => 'date',
        'fecha_verificacion' => 'date',
    ];

    // Relaciones
    public function conductor(): BelongsTo
    {
        return $this->belongsTo(Conductor::class, 'conductor_id');
    }

    public function viajes(): HasMany
    {
        return $this->hasMany(Viaje::class, 'conductor_id');
    }
}
