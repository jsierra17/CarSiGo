<?php

namespace Tests\Feature;

use App\Models\Conductor;
use App\Models\User;
use App\Models\Viaje;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ViajesFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_passenger_can_create_trip_and_conductor_can_accept_start_complete(): void
    {
        $pasajero = User::factory()->create([
            'tipo_usuario' => 'pasajero',
            'estado_cuenta' => 'activa',
        ]);

        Sanctum::actingAs($pasajero);

        $crear = $this->postJson('/api/viajes', [
            'origen_latitud' => 9.7170,
            'origen_longitud' => -75.1210,
            'origen_direccion' => 'Origen',
            'destino_latitud' => 9.7180,
            'destino_longitud' => -75.1220,
            'destino_direccion' => 'Destino',
        ]);

        $crear->assertStatus(201);
        $viajeId = $crear->json('data.id');

        $conductor = Conductor::factory()->create([
            'estado' => 'activo',
        ]);
        Wallet::factory()->create([
            'conductor_id' => $conductor->id,
            'balance' => 0,
            'status' => 'active',
            'limite_negativo' => -5000,
        ]);

        Sanctum::actingAs($conductor->usuario);

        $aceptar = $this->patchJson("/api/viajes/{$viajeId}/aceptar");
        $aceptar->assertStatus(200);

        $iniciar = $this->patchJson("/api/viajes/{$viajeId}/iniciar");
        $iniciar->assertStatus(200);

        $completar = $this->patchJson("/api/viajes/{$viajeId}/completar", [
            'distancia_estimada' => 3.5,
            'duracion_estimada' => 600,
            'precio_total' => 10000,
        ]);
        $completar->assertStatus(200);

        $this->assertDatabaseHas('viajes', [
            'id' => $viajeId,
            'estado' => 'completado',
        ]);
    }

    public function test_trip_update_only_allowed_for_owner_and_solicitado(): void
    {
        $pasajero = User::factory()->create(['tipo_usuario' => 'pasajero', 'estado_cuenta' => 'activa']);
        $otro = User::factory()->create(['tipo_usuario' => 'pasajero', 'estado_cuenta' => 'activa']);
        $viaje = Viaje::factory()->create(['pasajero_id' => $pasajero->id, 'estado' => 'solicitado']);

        Sanctum::actingAs($otro);
        $this->patchJson("/api/viajes/{$viaje->id}", ['origen_direccion' => 'X'])->assertStatus(403);

        Sanctum::actingAs($pasajero);
        $this->patchJson("/api/viajes/{$viaje->id}", ['origen_direccion' => 'Nuevo'])->assertStatus(200);

        $viaje->update(['estado' => 'asignado']);
        $this->patchJson("/api/viajes/{$viaje->id}", ['origen_direccion' => 'Otro'])->assertStatus(400);
    }

    public function test_complete_requires_validation(): void
    {
        $conductor = Conductor::factory()->create(['estado' => 'activo']);
        Wallet::factory()->create(['conductor_id' => $conductor->id]);
        $viaje = Viaje::factory()->asignado($conductor)->create(['estado' => 'en_progreso']);

        Sanctum::actingAs($conductor->usuario);
        $this->patchJson("/api/viajes/{$viaje->id}/completar", [
            'distancia_estimada' => 0,
        ])->assertStatus(422);
    }
}
