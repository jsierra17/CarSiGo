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
        Schema::create('comisiones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conductor_id')->constrained('conductores')->onDelete('cascade');
            $table->foreignId('pago_id')->constrained('pagos')->onDelete('cascade');
            
            // Información de comisión
            $table->decimal('monto_viaje', 10, 2);
            $table->decimal('porcentaje_comision', 5, 2);
            $table->decimal('monto_comision', 10, 2);
            $table->decimal('monto_neto_conductor', 10, 2);
            
            // Período
            $table->date('fecha_comisión');
            $table->integer('numero_quincena')->nullable(); // 1 o 2
            
            // Estado
            $table->enum('estado', ['pendiente', 'retenida', 'pagada', 'disputada'])->default('pendiente');
            
            // Información de pago
            $table->timestamp('fecha_pago')->nullable();
            $table->string('metodo_retiro')->nullable();
            
            // Deducciones (si aplican)
            $table->decimal('deduccion_daños', 10, 2)->default(0);
            $table->decimal('deduccion_multa', 10, 2)->default(0);
            $table->decimal('deduccion_otra', 10, 2)->default(0);
            $table->text('detalle_deducciones')->nullable();
            
            $table->timestamps();
            
            // Índices
            $table->index('conductor_id');
            $table->index('estado');
            $table->index('fecha_comisión');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('comisiones');
    }
};
