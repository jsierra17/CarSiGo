<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Configuracion extends Model
{
    protected $table = 'configuracion';

    protected $fillable = [
        'clave',
        'valor',
        'tipo_dato',
        'categoria',
        'descripcion',
        'valor_por_defecto',
        'editable',
        'valores_permitidos',
        'actualizada_por',
        'ultima_actualizacion',
        'grupo',
    ];

    protected $casts = [
        'editable' => 'boolean',
        'valores_permitidos' => 'json',
        'ultima_actualizacion' => 'datetime',
    ];

    public function actualizado_por()
    {
        return $this->belongsTo(User::class, 'actualizada_por');
    }

    /**
     * Obtener valor de configuración por clave
     */
    public static function obtener($clave, $default = null)
    {
        $config = self::where('clave', $clave)->first();
        return $config ? $config->valor : $default;
    }
}
