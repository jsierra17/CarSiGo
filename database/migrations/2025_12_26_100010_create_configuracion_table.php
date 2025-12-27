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
        Schema::create('configuracion', function (Blueprint $table) {
            $table->id();
            
            // Información básica
            $table->string('clave')->unique();
            $table->text('valor');
            $table->enum('tipo_dato', ['string', 'integer', 'decimal', 'boolean', 'json'])->default('string');
            
            // Categoría
            $table->enum('categoria', [
                'general',
                'precios',
                'comisiones',
                'seguridad',
                'notificaciones',
                'integraciones',
                'limites',
                'mantenimiento'
            ])->default('general');
            
            // Descripción y valores
            $table->text('descripcion');
            $table->text('valor_por_defecto')->nullable();
            $table->boolean('editable')->default(true);
            $table->text('valores_permitidos')->nullable(); // JSON array para restricciones
            
            // Información de actualización
            $table->foreignId('actualizada_por')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('ultima_actualizacion')->nullable();
            
            // Grupo
            $table->string('grupo')->nullable(); // para agrupar configuraciones relacionadas
            
            $table->timestamps();
            
            // Índices
            $table->index('clave');
            $table->index('categoria');
            $table->index('grupo');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('configuracion');
    }
};
