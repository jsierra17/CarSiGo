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
        Schema::create('promociones', function (Blueprint $table) {
            $table->id();
            
            // Información básica
            $table->string('codigo')->unique();
            $table->string('nombre');
            $table->text('descripcion');
            
            // Tipo de promoción
            $table->enum('tipo', [
                'descuento_porcentaje',
                'descuento_fijo',
                'viaje_gratis',
                'credito_bienvenida',
                'referencia'
            ])->default('descuento_porcentaje');
            
            // Valores
            $table->decimal('valor', 10, 2);
            $table->decimal('valor_minimo_viaje', 10, 2)->nullable();
            $table->integer('usos_maximos')->nullable();
            $table->integer('usos_por_usuario')->default(1);
            
            // Período de validez
            $table->timestamp('fecha_inicio');
            $table->timestamp('fecha_vencimiento');
            $table->boolean('activa')->default(true);
            
            // Aplicabilidad
            $table->enum('aplica_a', ['todos', 'nuevos_usuarios', 'usuarios_existentes', 'conductores'])->default('todos');
            $table->string('ciudad_aplicable')->nullable(); // El Carmen de Bolívar, Cartagena, etc
            
            // Información de uso
            $table->integer('veces_usado')->default(0);
            $table->integer('presupuesto_total')->nullable(); // Máximo gasto en promociones
            $table->decimal('gasto_total', 12, 2)->default(0);
            
            // Información adicional
            $table->text('terminos_condiciones')->nullable();
            $table->boolean('requiere_codigo_referencia')->default(false);
            $table->string('codigo_referencia_requerido')->nullable();
            
            // Auditoría
            $table->foreignId('creada_por')->nullable()->constrained('users')->onDelete('set null');
            
            $table->timestamps();
            $table->softDeletes();
            
            // Índices
            $table->index('codigo');
            $table->index('activa');
            $table->index('fecha_vencimiento');
            $table->index('aplica_a');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('promociones');
    }
};
