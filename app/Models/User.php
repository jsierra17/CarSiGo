<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'telefono',
        'genero',
        'fecha_nacimiento',
        'numero_documento',
        'tipo_documento',
        'ciudad',
        'departamento',
        'pais',
        'direccion',
        'tipo_usuario',
        'estado_cuenta',
        'email_verificado',
        'email_verificado_at',
        'telefono_verificado',
        'telefono_verificado_at',
        'recibir_notificaciones',
        'recibir_promociones',
        'preferencias',
        'foto_perfil_url',
        'bio',
        'contacto_emergencia_nombre',
        'contacto_emergencia_telefono',
        'referido_por',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'fecha_nacimiento' => 'date',
            'email_verificado' => 'boolean',
            'email_verificado_at' => 'datetime',
            'telefono_verificado' => 'boolean',
            'telefono_verificado_at' => 'datetime',
            'recibir_notificaciones' => 'boolean',
            'recibir_promociones' => 'boolean',
            'preferencias' => 'json',
            'ultima_sesion_exitosa' => 'datetime',
            'ultimo_intento_fallido' => 'datetime',
        ];
    }

    /**
     * Relaciones
     */

    public function conductor()
    {
        return $this->hasOne(Conductor::class, 'usuario_id');
    }

    public function viajes_como_pasajero()
    {
        return $this->hasMany(Viaje::class, 'pasajero_id');
    }

    public function pagos_como_pasajero()
    {
        return $this->hasMany(Pago::class, 'pasajero_id');
    }

    public function ubicaciones_como_pasajero()
    {
        return $this->hasMany(Ubicacion::class, 'pasajero_id');
    }

    public function emergencias()
    {
        return $this->hasMany(Emergencia::class, 'usuario_id');
    }

    public function tickets_soporte()
    {
        return $this->hasMany(SoporteTicket::class, 'usuario_id');
    }

    public function logs_sistema()
    {
        return $this->hasMany(LogSistema::class, 'usuario_id');
    }

    /**
     * Scopos útiles
     */

    public function scopePasajeros($query)
    {
        return $query->where('tipo_usuario', 'pasajero');
    }

    public function scopeConductores($query)
    {
        return $query->where('tipo_usuario', 'conductor');
    }

    public function scopeAdministradores($query)
    {
        return $query->where('tipo_usuario', 'admin');
    }

    public function scopeSoporteTecnico($query)
    {
        return $query->where('tipo_usuario', 'soporte');
    }

    public function scopeActivos($query)
    {
        return $query->where('estado_cuenta', 'activa');
    }
}
