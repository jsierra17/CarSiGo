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
        Schema::create('chat_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('viaje_id')->constrained('viajes')->onDelete('cascade');
            $table->foreignId('remitente_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('destinatario_id')->constrained('users')->onDelete('cascade');
            $table->text('contenido');
            $table->string('tipo')->default('texto'); // texto, imagen, ubicacion, sistema
            $table->json('metadata')->nullable(); // datos adicionales según el tipo
            $table->timestamp('leido_en')->nullable();
            $table->boolean('eliminado_por_remitente')->default(false);
            $table->boolean('eliminado_por_destinatario')->default(false);
            $table->timestamps();

            // Índices
            $table->index(['viaje_id', 'created_at']);
            $table->index(['remitente_id', 'destinatario_id']);
            $table->index(['destinatario_id', 'leido_en']);
            $table->index('tipo');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('chat_messages');
    }
};
