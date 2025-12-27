<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LogSistema extends Model
{
    protected $table = 'logs_sistema';

    protected $fillable = [
        'tipo_evento',
        'usuario_id',
        'email_usuario',
        'tipo_usuario',
        'entidad',
        'id_entidad',
        'descripcion',
        'datos_adicionales',
        'ip_address',
        'user_agent',
        'navegador',
        'sistema_operativo',
        'latitud',
        'longitud',
        'estado',
        'mensaje_error',
        'modulo',
        'accion',
    ];

    protected $casts = [
        'latitud' => 'decimal:8',
        'longitud' => 'decimal:8',
        'datos_adicionales' => 'json',
    ];

    public function usuario()
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }
}
