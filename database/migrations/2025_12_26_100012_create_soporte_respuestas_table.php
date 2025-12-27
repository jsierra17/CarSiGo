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
        Schema::create('soporte_respuestas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ticket_id')->constrained('soporte_tickets')->onDelete('cascade');
            $table->foreignId('usuario_id')->constrained('users')->onDelete('cascade');
            $table->text('mensaje');
            $table->boolean('es_respuesta_staff')->default(false);
            $table->timestamps();
            
            // Índices para optimizar búsquedas
            $table->index('ticket_id');
            $table->index('usuario_id');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('soporte_respuestas');
    }
};
