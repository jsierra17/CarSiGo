<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ChatMessage extends Model
{
    use HasFactory;

    protected $fillable = [
        'viaje_id',
        'remitente_id',
        'destinatario_id',
        'contenido',
        'tipo',
        'metadata',
        'leido_en',
        'eliminado_por_remitente',
        'eliminado_por_destinatario',
    ];

    protected $casts = [
        'metadata' => 'array',
        'leido_en' => 'datetime',
        'eliminado_por_remitente' => 'boolean',
        'eliminado_por_destinatario' => 'boolean',
    ];

    /**
     * Get the viaje that owns the message.
     */
    public function viaje(): BelongsTo
    {
        return $this->belongsTo(Viaje::class);
    }

    /**
     * Get the remitente that owns the message.
     */
    public function remitente(): BelongsTo
    {
        return $this->belongsTo(User::class, 'remitente_id');
    }

    /**
     * Get the destinatario that owns the message.
     */
    public function destinatario(): BelongsTo
    {
        return $this->belongsTo(User::class, 'destinatario_id');
    }

    /**
     * Mark message as read.
     */
    public function marcarComoLeido(): bool
    {
        return $this->update(['leido_en' => now()]);
    }

    /**
     * Check if message is read.
     */
    public function estaLeido(): bool
    {
        return $this->leido_en !== null;
    }

    /**
     * Scope a query to only include unread messages.
     */
    public function scopeNoLeidos($query)
    {
        return $query->whereNull('leido_en');
    }

    /**
     * Scope a query to only include messages between two users.
     */
    public function scopeEntreUsuarios($query, $userId1, $userId2)
    {
        return $query->where(function ($q) use ($userId1, $userId2) {
            $q->where(function ($subQuery) use ($userId1, $userId2) {
                $subQuery->where('remitente_id', $userId1)
                         ->where('destinatario_id', $userId2);
            })->orWhere(function ($subQuery) use ($userId1, $userId2) {
                $subQuery->where('remitente_id', $userId2)
                         ->where('destinatario_id', $userId1);
            });
        });
    }

    /**
     * Get unread messages count for a user.
     */
    public static function noLeidosCount($userId): int
    {
        return static::where('destinatario_id', $userId)
                    ->whereNull('leido_en')
                    ->where('eliminado_por_destinatario', false)
                    ->count();
    }
}
