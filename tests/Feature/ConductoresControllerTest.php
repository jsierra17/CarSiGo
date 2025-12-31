<?php

namespace Tests\Feature;

use App\Models\Conductor;
use App\Models\User;
use App\Models\Vehiculo;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ConductoresControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_index_requires_admin_or_support(): void
    {
        $pasajero = User::factory()->create(['tipo_usuario' => 'pasajero', 'estado_cuenta' => 'activa']);
        Sanctum::actingAs($pasajero);

        $this->getJson('/api/conductores')->assertStatus(403);

        $admin = User::factory()->create(['tipo_usuario' => 'admin', 'estado_cuenta' => 'activa']);
        Sanctum::actingAs($admin);

        $this->getJson('/api/conductores')->assertStatus(200);
    }

    public function test_conductor_can_view_own_profile(): void
    {
        $conductor = Conductor::factory()->create(['estado' => 'activo']);
        Vehiculo::factory()->create(['conductor_id' => $conductor->id]);
        Wallet::factory()->create(['conductor_id' => $conductor->id]);

        Sanctum::actingAs($conductor->usuario);

        $this->getJson('/api/conductores/mi-perfil')->assertStatus(200);
    }

    public function test_conductor_can_upload_document_to_private_disk(): void
    {
        Storage::fake('private');

        $conductor = Conductor::factory()->create(['estado' => 'activo']);
        Wallet::factory()->create(['conductor_id' => $conductor->id]);

        Sanctum::actingAs($conductor->usuario);

        $file = UploadedFile::fake()->create('licencia.pdf', 100, 'application/pdf');

        $resp = $this->postJson('/api/conductores/documentos/subir', [
            'tipo_documento' => 'licencia',
            'archivo' => $file,
        ]);

        $resp->assertStatus(201);
    }
}
