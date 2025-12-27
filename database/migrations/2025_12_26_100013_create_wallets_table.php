<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conductor_id')->constrained('conductores')->onDelete('cascade');
            $table->decimal('balance', 15, 2)->default(0);
            $table->enum('status', ['active', 'blocked'])->default('active');
            $table->decimal('limite_negativo', 15, 2)->default(-5000);
            $table->timestamps();

            $table->unique('conductor_id');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallets');
    }
};
