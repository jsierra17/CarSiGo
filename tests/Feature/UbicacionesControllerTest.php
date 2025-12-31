<?php

namespace Tests\Feature;

use App\Models\Conductor;
use App\Models\Ubicacion;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class UbicacionesControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_conductor_can_report_location_and_sets_estado_conexion_en_linea(): void
    {
        $conductor = Conductor::factory()->create(['estado' => 'activo', 'estado_conexion' => 'fuera_linea']);
        Wallet::factory()->create(['conductor_id' => $conductor->id]);

        Sanctum::actingAs($conductor->usuario);

        $resp = $this->postJson('/api/ubicaciones/reportar', [
            'latitud' => 9.7170,
            'longitud' => -75.1210,
            'precision' => 5,
        ]);

        $resp->assertStatus(201);

        $conductor->refresh();
        $this->assertSame('en_linea', $conductor->estado_conexion);
        $this->assertDatabaseHas('ubicaciones', ['conductor_id' => $conductor->id]);
    }

    public function test_conductores_cercanos_returns_results_for_online_active_conductors(): void
    {
        $this->withoutExceptionHandling();

        $conductor = Conductor::factory()->create(['estado' => 'activo', 'estado_conexion' => 'en_linea']);
        Ubicacion::factory()->create([
            'tipo' => 'conductor',
            'conductor_id' => $conductor->id,
            'latitud' => 9.7170,
            'longitud' => -75.1210,
            'timestamp_ubicacion' => now(),
        ]);

        Sanctum::actingAs($conductor->usuario);

        $resp = $this->getJson('/api/ubicaciones/conductores/cercanos?latitud=9.7170&longitud=-75.1210&radio=5');
        if ($resp->status() !== 200) {
            $this->fail($resp->getContent());
        }

        $resp->assertStatus(200);
    }
}
