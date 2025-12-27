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
        Schema::create('pagos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('viaje_id')->constrained('viajes')->onDelete('cascade');
            $table->foreignId('pasajero_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('conductor_id')->constrained('conductores')->onDelete('cascade');
            
            // Información del pago
            $table->decimal('monto_subtotal', 10, 2);
            $table->decimal('impuesto', 10, 2)->default(0);
            $table->decimal('descuento', 10, 2)->default(0);
            $table->decimal('monto_total', 10, 2);
            
            // Comisión y ganancias
            $table->decimal('comision_plataforma', 10, 2);
            $table->decimal('monto_conductor', 10, 2);
            
            // Método de pago
            $table->enum('metodo_pago', [
                'efectivo',
                'tarjeta_credito',
                'tarjeta_debito',
                'billetera_digital',
                'transferencia_bancaria',
                'nequi',
                'daviplata'
            ])->default('efectivo');
            
            // Estado del pago
            $table->enum('estado', [
                'pendiente',
                'procesando',
                'completado',
                'fallido',
                'reembolsado',
                'disputado'
            ])->default('pendiente');
            
            // Referencias de transacción
            $table->string('numero_transaccion')->nullable()->unique();
            $table->string('referencia_proveedor')->nullable();
            $table->text('respuesta_proveedor')->nullable();
            
            // Fechas
            $table->timestamp('fecha_solicitud');
            $table->timestamp('fecha_procesamiento')->nullable();
            $table->timestamp('fecha_completacion')->nullable();
            
            // Información adicional
            $table->text('notas')->nullable();
            $table->boolean('requiere_comprobante')->default(false);
            
            $table->timestamps();
            $table->softDeletes();
            
            // Índices
            $table->index('viaje_id');
            $table->index('pasajero_id');
            $table->index('conductor_id');
            $table->index('estado');
            $table->index('metodo_pago');
            $table->index('fecha_solicitud');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pagos');
    }
};
