<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('logs_sistema', function (Blueprint $table) {
            $table->id();
            
            // Información del evento
            $table->enum('tipo_evento', [
                'inicio_sesion',
                'cierre_sesion',
                'inicio_viaje',
                'fin_viaje',
                'pago_procesado',
                'error_sistema',
                'cambio_configuracion',
                'acceso_recurso',
                'intento_fraude',
                'otro'
            ])->default('otro');
            
            // Usuario involucrado
            $table->foreignId('usuario_id')->nullable()->constrained('users')->onDelete('cascade');
            $table->string('email_usuario')->nullable();
            $table->string('tipo_usuario')->nullable(); // pasajero, conductor, admin, soporte
            
            // Detalles del evento
            $table->string('entidad')->nullable(); // viaje, usuario, pago, etc
            $table->string('id_entidad')->nullable();
            $table->text('descripcion');
            $table->text('datos_adicionales')->nullable(); // JSON
            
            // Información técnica
            $table->string('ip_address')->nullable();
            $table->string('user_agent')->nullable();
            $table->string('navegador')->nullable();
            $table->string('sistema_operativo')->nullable();
            
            // Ubicación (si aplica)
            $table->decimal('latitud', 10, 8)->nullable();
            $table->decimal('longitud', 11, 8)->nullable();
            
            // Estado
            $table->enum('estado', ['exitoso', 'fallo', 'advertencia', 'info'])->default('info');
            $table->text('mensaje_error')->nullable();
            
            // Auditoría y rastreo
            $table->string('modulo')->nullable(); // auth, viajes, pagos, soporte
            $table->string('accion')->nullable(); // crear, actualizar, eliminar, leer
            
            $table->timestamps();
            
            // Índices para búsqueda y análisis rápido
            $table->index('usuario_id');
            $table->index('tipo_evento');
            $table->index('entidad');
            $table->index('estado');
            $table->index('created_at');
            $table->index(['usuario_id', 'created_at']);
            $table->index(['tipo_evento', 'estado']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('logs_sistema');
    }
};
