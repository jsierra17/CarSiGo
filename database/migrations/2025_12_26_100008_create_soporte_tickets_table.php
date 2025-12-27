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
        Schema::create('soporte_tickets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('viaje_id')->nullable()->constrained('viajes')->onDelete('cascade');
            
            // Información básica
            $table->string('numero_ticket')->unique();
            $table->string('asunto');
            $table->text('descripcion');
            
            // Categoría
            $table->enum('categoria', [
                'viaje',
                'pago',
                'conductor',
                'pasajero',
                'vehiculo',
                'app',
                'otro'
            ])->default('otro');
            
            // Prioridad y estado
            $table->enum('prioridad', ['baja', 'media', 'alta', 'critica'])->default('media');
            $table->enum('estado', ['abierto', 'en_progreso', 'esperando_usuario', 'resuelto', 'cerrado'])->default('abierto');
            
            // Respuestas automáticas
            $table->boolean('respondido_por_llm')->default(false);
            $table->text('respuesta_automatica')->nullable();
            $table->boolean('usuario_acepta_respuesta_llm')->nullable();
            
            // Respuesta manual
            $table->foreignId('respondido_por')->nullable()->constrained('users')->onDelete('set null');
            $table->text('respuesta_manual')->nullable();
            $table->timestamp('hora_respuesta')->nullable();
            
            // Resolución
            $table->text('resolucion')->nullable();
            $table->timestamp('hora_resolucion')->nullable();
            
            // Rating
            $table->integer('satisfaccion')->nullable(); // 1-5
            $table->text('comentario_satisfaccion')->nullable();
            
            // Escalado
            $table->boolean('requiere_escalado')->default(false);
            $table->string('escalado_a')->nullable(); // gerente, director, etc
            
            $table->timestamps();
            $table->softDeletes();
            
            // Índices
            $table->index('usuario_id');
            $table->index('viaje_id');
            $table->index('numero_ticket');
            $table->index('estado');
            $table->index('prioridad');
            $table->index('categoria');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('soporte_tickets');
    }
};
