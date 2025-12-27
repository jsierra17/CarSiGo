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
        Schema::table('users', function (Blueprint $table) {
            // Información personal adicional
            $table->string('telefono')->nullable()->unique();
            $table->enum('genero', ['masculino', 'femenino', 'otro', 'prefiero_no_decir'])->nullable();
            $table->date('fecha_nacimiento')->nullable();
            
            // Documentación
            $table->string('numero_documento')->nullable()->unique();
            $table->enum('tipo_documento', ['cedula', 'pasaporte', 'otro'])->default('cedula');
            
            // Ubicación
            $table->string('ciudad')->default('El Carmen de Bolívar');
            $table->string('departamento')->default('Bolívar');
            $table->string('pais')->default('Colombia');
            $table->string('direccion')->nullable();
            
            // Rol en la plataforma
            $table->enum('tipo_usuario', ['pasajero', 'conductor', 'admin', 'soporte'])->default('pasajero');
            
            // Estado de cuenta
            $table->enum('estado_cuenta', ['activa', 'inactiva', 'suspendida', 'verificacion'])->default('verificacion');
            $table->boolean('email_verificado')->default(false);
            $table->timestamp('email_verificado_at')->nullable();
            $table->boolean('telefono_verificado')->default(false);
            $table->timestamp('telefono_verificado_at')->nullable();
            
            // Preferencias
            $table->boolean('recibir_notificaciones')->default(true);
            $table->boolean('recibir_promociones')->default(true);
            $table->json('preferencias')->nullable();
            
            // Información de perfil
            $table->text('foto_perfil_url')->nullable();
            $table->text('bio')->nullable();
            
            // Contactos de emergencia (para conductores principalmente)
            $table->string('contacto_emergencia_nombre')->nullable();
            $table->string('contacto_emergencia_telefono')->nullable();
            
            // Datos de seguridad
            $table->timestamp('ultima_sesion_exitosa')->nullable();
            $table->timestamp('ultimo_intento_fallido')->nullable();
            $table->integer('intentos_fallidos_consecutivos')->default(0);
            
            // Auditoría
            $table->timestamp('fecha_creacion_account')->useCurrent();
            $table->string('referido_por')->nullable(); // para tracking de referidos
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
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
                'ultima_sesion_exitosa',
                'ultimo_intento_fallido',
                'intentos_fallidos_consecutivos',
                'fecha_creacion_account',
                'referido_por'
            ]);
        });
    }
};
