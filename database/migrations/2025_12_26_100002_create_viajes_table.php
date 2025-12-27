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
        Schema::create('viajes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pasajero_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('conductor_id')->nullable()->constrained('conductores')->onDelete('set null');
            
            // Información de ubicación
            // Nota: Para geolocalización con PostGIS, usar: php artisan make:migration add_geometry_to_viajes
            $table->decimal('origen_latitud', 10, 8);
            $table->decimal('origen_longitud', 11, 8);
            $table->string('origen_direccion');
            $table->string('origen_lugar')->nullable();
            
            $table->decimal('destino_latitud', 10, 8);
            $table->decimal('destino_longitud', 11, 8);
            $table->string('destino_direccion');
            $table->string('destino_lugar')->nullable();
            
            // Tipo de viaje
            $table->enum('tipo', ['estandar', 'compartido', 'urgente'])->default('estandar');
            $table->integer('pasajeros_solicitados')->default(1);
            
            // Información de ruta
            $table->decimal('distancia_estimada', 8, 2)->nullable(); // en km
            $table->integer('duracion_estimada')->nullable(); // en segundos
            $table->decimal('tarifa_base', 8, 2);
            $table->decimal('precio_total', 10, 2)->nullable();
            
            // Estado del viaje
            $table->enum('estado', [
                'solicitado',
                'asignado',
                'conductor_en_ruta',
                'en_progreso',
                'completado',
                'cancelado',
                'no_presentado'
            ])->default('solicitado');
            
            // Tiempos
            $table->timestamp('hora_solicitud');
            $table->timestamp('hora_asignacion')->nullable();
            $table->timestamp('hora_inicio')->nullable();
            $table->timestamp('hora_finalizacion')->nullable();
            
            // Calificación
            $table->integer('calificacion_pasajero')->nullable(); // 1-5
            $table->integer('calificacion_conductor')->nullable(); // 1-5
            $table->text('comentario_pasajero')->nullable();
            $table->text('comentario_conductor')->nullable();
            
            // Información adicional
            $table->text('notas_especiales')->nullable();
            $table->text('incidentes')->nullable();
            $table->boolean('requiere_factura')->default(false);
            
            // Cancelación
            $table->string('razon_cancelacion')->nullable();
            $table->string('cancelado_por')->nullable(); // pasajero, conductor, sistema
            
            $table->timestamps();
            $table->softDeletes();
            
            // Índices
            $table->index('pasajero_id');
            $table->index('conductor_id');
            $table->index('estado');
            $table->index('hora_solicitud');
            $table->index(['origen_latitud', 'origen_longitud']);
            $table->index(['destino_latitud', 'destino_longitud']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('viajes');
    }
};
