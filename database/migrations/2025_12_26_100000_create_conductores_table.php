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
        Schema::create('conductores', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('users')->onDelete('cascade');
            
            // Información personal
            $table->string('numero_licencia')->unique();
            $table->date('fecha_vencimiento_licencia');
            $table->string('tipo_licencia'); // A1, A2, B, C, etc
            $table->enum('estado', ['activo', 'inactivo', 'suspendido', 'verificacion'])->default('verificacion');
            
            // Verificación y documentos
            $table->boolean('documentos_verificados')->default(false);
            $table->boolean('antecedentes_limpios')->default(false);
            $table->date('fecha_ultima_verificacion')->nullable();
            
            // Ratings
            $table->decimal('calificacion_promedio', 3, 2)->default(5.00);
            $table->integer('total_viajes')->default(0);
            $table->integer('total_calificaciones')->default(0);
            
            // Comisión y ganancias
            $table->decimal('comision_porcentaje', 5, 2)->default(5.00);
            $table->decimal('ganancias_totales', 12, 2)->default(0);
            $table->decimal('saldo_pendiente', 12, 2)->default(0);
            
            // Estado en tiempo real
            $table->enum('estado_conexion', ['en_linea', 'fuera_linea', 'en_viaje'])->default('fuera_linea');
            $table->timestamp('ultima_conexion')->nullable();
            
            // Información de seguro
            $table->string('numero_aseguranza')->nullable();
            $table->date('vencimiento_aseguranza')->nullable();
            $table->string('compania_aseguranza')->nullable();
            
            $table->timestamps();
            $table->softDeletes();
            
            // Índices
            $table->index('estado');
            $table->index('estado_conexion');
            $table->index('calificacion_promedio');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('conductores');
    }
};
