<?php

namespace Tests\Feature;

use App\Models\Conductor;
use App\Models\SoporteTicket;
use App\Models\User;
use App\Models\Viaje;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SoporteControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_only_passenger_or_conductor_can_create_ticket(): void
    {
        $admin = User::factory()->create(['tipo_usuario' => 'admin', 'estado_cuenta' => 'activa']);
        Sanctum::actingAs($admin);

        $this->postJson('/api/soporte/tickets', [
            'asunto' => 'A',
            'descripcion' => 'Descripcion valida de prueba',
            'categoria' => 'otro',
        ])->assertStatus(403);
    }

    public function test_passenger_can_create_ticket_and_list_own_tickets(): void
    {
        $pasajero = User::factory()->create(['tipo_usuario' => 'pasajero', 'estado_cuenta' => 'activa']);
        Sanctum::actingAs($pasajero);

        $create = $this->postJson('/api/soporte/tickets', [
            'asunto' => 'Problema',
            'descripcion' => 'Descripcion valida de prueba',
            'categoria' => 'otro',
        ]);

        $create->assertStatus(201);

        $list = $this->getJson('/api/soporte/tickets');
        $list->assertStatus(200);
    }

    public function test_staff_can_update_ticket_status(): void
    {
        $staff = User::factory()->create(['tipo_usuario' => 'soporte', 'estado_cuenta' => 'activa']);
        $ticket = SoporteTicket::factory()->create();

        Sanctum::actingAs($staff);

        $this->patchJson("/api/soporte/tickets/{$ticket->id}/estado", [
            'estado' => 'en_progreso',
        ])->assertStatus(200);
    }
}
