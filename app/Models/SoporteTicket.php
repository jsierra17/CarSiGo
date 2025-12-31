<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class SoporteTicket extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'soporte_tickets';

    protected $fillable = [
        'usuario_id',
        'viaje_id',
        'numero_ticket',
        'asunto',
        'descripcion',
        'categoria',
        'prioridad',
        'estado',
        'respondido_por_llm',
        'respuesta_automatica',
        'usuario_acepta_respuesta_llm',
        'respondido_por',
        'respuesta_manual',
        'hora_respuesta',
        'resolucion',
        'hora_resolucion',
        'satisfaccion',
        'comentario_satisfaccion',
        'requiere_escalado',
        'escalado_a',
    ];

    protected $casts = [
        'respondido_por_llm' => 'boolean',
        'usuario_acepta_respuesta_llm' => 'boolean',
        'requiere_escalado' => 'boolean',
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

    public function respondido_por_usuario(): BelongsTo
    {
        return $this->belongsTo(User::class, 'respondido_por');
    }

    /**
     * Obtener todas las respuestas del ticket
     */
    public function respuestas()
    {
        return $this->hasMany(SoporteRespuesta::class, 'ticket_id');
    }
}
