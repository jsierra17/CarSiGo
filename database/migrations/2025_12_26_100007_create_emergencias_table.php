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
        Schema::create('emergencias', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('viaje_id')->nullable()->constrained('viajes')->onDelete('cascade');
            
            // Tipo de emergencia
            $table->enum('tipo', [
                'accidente',
                'asalto',
                'acoso',
                'problema_medico',
                'conductor_comportamiento_inapropiado',
                'pasajero_comportamiento_inapropiado',
                'problema_mecanico',
                'otro'
            ])->default('otro');
            
            // Información de ubicación
            $table->decimal('latitud', 10, 8);
            $table->decimal('longitud', 11, 8);
            $table->string('direccion')->nullable();
            
            // Estado
            $table->enum('estado', ['activa', 'respondida', 'resuelta', 'cancelada'])->default('activa');
            $table->enum('prioridad', ['baja', 'media', 'alta', 'critica'])->default('alta');
            
            // Respuesta
            $table->string('respondida_por')->nullable();
            $table->timestamp('hora_respuesta')->nullable();
            $table->timestamp('hora_resolucion')->nullable();
            $table->text('descripcion_resolucion')->nullable();
            
            // Información adicional
            $table->text('descripcion');
            $table->string('numero_contacto_emergencia')->nullable();
            $table->boolean('requiere_policia')->default(false);
            $table->boolean('requiere_ambulancia')->default(false);
            $table->string('numero_reporte_policia')->nullable();
            
            // Auditoría
            $table->text('notas_internas')->nullable();
            
            $table->timestamps();
            $table->softDeletes();
            
            // Índices
            $table->index('usuario_id');
            $table->index('viaje_id');
            $table->index('estado');
            $table->index('tipo');
            $table->index('prioridad');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('emergencias');
    }
};
