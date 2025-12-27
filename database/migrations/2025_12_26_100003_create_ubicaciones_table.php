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
        Schema::create('ubicaciones', function (Blueprint $table) {
            $table->id();
            
            // Tipo de ubicación
            $table->enum('tipo', ['conductor', 'pasajero_en_viaje', 'ubicacion_interes'])->default('conductor');
            
            // Referencias
            $table->foreignId('conductor_id')->nullable()->constrained('conductores')->onDelete('cascade');
            $table->foreignId('pasajero_id')->nullable()->constrained('users')->onDelete('cascade');
            $table->foreignId('viaje_id')->nullable()->constrained('viajes')->onDelete('cascade');
            
            // Coordenadas
            $table->decimal('latitud', 10, 8);
            $table->decimal('longitud', 11, 8);
            $table->decimal('precision', 5, 2)->nullable(); // en metros
            
            // Dirección
            $table->string('direccion')->nullable();
            $table->string('ciudad')->nullable();
            $table->string('departamento')->nullable();
            $table->string('codigo_postal')->nullable();
            
            // Información adicional
            $table->text('descripcion')->nullable();
            $table->enum('estado', ['activa', 'archivada'])->default('activa');
            
            // Geolocalización en tiempo real
            $table->timestamp('timestamp_ubicacion');
            $table->string('proveedor')->default('gps'); // gps, red, fusionado
            
            // Velocidad y dirección (si disponible)
            $table->decimal('velocidad', 5, 2)->nullable(); // km/h
            $table->decimal('rumbo', 5, 2)->nullable(); // grados (0-360)
            
            $table->timestamps();
            
            // Índices
            $table->index(['conductor_id', 'timestamp_ubicacion']);
            $table->index(['pasajero_id', 'timestamp_ubicacion']);
            $table->index(['latitud', 'longitud']);
            $table->index('timestamp_ubicacion');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ubicaciones');
    }
};
