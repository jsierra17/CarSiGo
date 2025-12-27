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
        Schema::create('vehiculos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conductor_id')->constrained('conductores')->onDelete('cascade');
            
            // Información básica
            $table->string('placa')->unique();
            $table->string('marca');
            $table->string('modelo');
            $table->integer('anio');
            $table->string('color');
            
            // Categoría de servicio
            $table->enum('categoria', ['basico', 'confort', 'premium', 'compartido'])->default('basico');
            $table->integer('capacidad_pasajeros')->default(4);
            
            // Documentación
            $table->string('numero_chasis')->unique();
            $table->string('numero_motor')->unique();
            $table->string('numero_soat')->unique();
            $table->date('vencimiento_soat');
            $table->string('numero_tecnica_mecanica')->nullable();
            $table->date('vencimiento_tecnica')->nullable();
            
            // Permisos y registros
            $table->string('numero_permisoOperativo')->unique();
            $table->date('vencimiento_permiso');
            $table->boolean('documentos_vigentes')->default(true);
            
            // Estado
            $table->enum('estado', ['activo', 'inactivo', 'mantenimiento', 'rechazado'])->default('inactivo');
            $table->text('observaciones')->nullable();
            
            // Información de seguridad
            $table->boolean('tiene_gps')->default(true);
            $table->boolean('tiene_boton_panico')->default(true);
            $table->boolean('tiene_camara')->default(false);
            
            // Mantenimiento
            $table->date('proxima_revision')->nullable();
            $table->integer('kilometraje')->default(0);
            
            // Auditoría
            $table->date('fecha_verificacion')->nullable();
            $table->string('verificado_por')->nullable();
            
            $table->timestamps();
            $table->softDeletes();
            
            // Índices
            $table->index('conductor_id');
            $table->index('categoria');
            $table->index('estado');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vehiculos');
    }
};
