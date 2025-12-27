<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SoporteRespuesta extends Model
{
    protected $table = 'soporte_respuestas';

    protected $fillable = [
        'ticket_id',
        'usuario_id',
        'mensaje',
        'es_respuesta_staff',
    ];

    protected $casts = [
        'es_respuesta_staff' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // ========================
    // RELACIONES
    // ========================

    /**
     * Obtener el ticket al que pertenece esta respuesta
     */
    public function ticket(): BelongsTo
    {
        return $this->belongsTo(SoporteTicket::class, 'ticket_id');
    }

    /**
     * Obtener el usuario que realizó la respuesta
     */
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }
}
