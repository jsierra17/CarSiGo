<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Conductor extends Model
{
    use SoftDeletes;

    protected $table = 'conductores';

    protected $fillable = [
        'usuario_id',
        'numero_licencia',
        'fecha_vencimiento_licencia',
        'tipo_licencia',
        'estado',
        'documentos_verificados',
        'antecedentes_limpios',
        'fecha_ultima_verificacion',
        'calificacion_promedio',
        'total_viajes',
        'total_calificaciones',
        'comision_porcentaje',
        'ganancias_totales',
        'saldo_pendiente',
        'estado_conexion',
        'ultima_conexion',
        'numero_aseguranza',
        'vencimiento_aseguranza',
        'compania_aseguranza',
    ];

    protected $casts = [
        'documentos_verificados' => 'boolean',
        'antecedentes_limpios' => 'boolean',
        'fecha_ultima_verificacion' => 'date',
        'fecha_vencimiento_licencia' => 'date',
        'vencimiento_aseguranza' => 'date',
        'calificacion_promedio' => 'decimal:2',
        'ganancias_totales' => 'decimal:2',
        'saldo_pendiente' => 'decimal:2',
        'comision_porcentaje' => 'decimal:2',
        'ultima_conexion' => 'datetime',
    ];

    // Relaciones
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    public function vehiculos(): HasMany
    {
        return $this->hasMany(Vehiculo::class, 'conductor_id');
    }

    public function viajes(): HasMany
    {
        return $this->hasMany(Viaje::class, 'conductor_id');
    }

    public function pagos(): HasMany
    {
        return $this->hasMany(Pago::class, 'conductor_id');
    }

    public function comisiones(): HasMany
    {
        return $this->hasMany(Comision::class, 'conductor_id');
    }

    public function ubicaciones(): HasMany
    {
        return $this->hasMany(Ubicacion::class, 'conductor_id');
    }

    public function wallet()
    {
        return $this->hasOne(Wallet::class, 'conductor_id');
    }
}
