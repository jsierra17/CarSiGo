<?php

namespace Tests\Feature;

use App\Models\Conductor;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_passenger_creates_user_in_verificacion_state(): void
    {
        $response = $this->postJson('/api/auth/registro', [
            'name' => 'Test Pasajero',
            'email' => 'pasajero@example.com',
            'password' => 'Password123',
            'password_confirmation' => 'Password123',
            'tipo_usuario' => 'pasajero',
            'telefono' => '+573001112233',
            'numero_documento' => '1234567890',
        ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('users', [
            'email' => 'pasajero@example.com',
            'tipo_usuario' => 'pasajero',
            'estado_cuenta' => 'verificacion',
        ]);
    }

    public function test_register_conductor_creates_conductor_record(): void
    {
        $response = $this->postJson('/api/auth/registro', [
            'name' => 'Test Conductor',
            'email' => 'conductor@example.com',
            'password' => 'Password123',
            'password_confirmation' => 'Password123',
            'tipo_usuario' => 'conductor',
            'telefono' => '+573001112234',
            'numero_documento' => '1234567891',
            'numero_licencia' => 'LIC-00000001',
            'fecha_vencimiento_licencia' => now()->addYear()->toDateString(),
        ]);

        $response->assertStatus(201);

        $user = User::where('email', 'conductor@example.com')->firstOrFail();

        $this->assertDatabaseHas('conductores', [
            'usuario_id' => $user->id,
            'estado' => 'verificacion',
        ]);
    }

    public function test_login_requires_active_account(): void
    {
        $user = User::factory()->create([
            'email' => 'inactive@example.com',
            'password' => Hash::make('Password123'),
            'estado_cuenta' => 'verificacion',
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'Password123',
        ]);

        $response->assertStatus(403);
    }

    public function test_failed_login_increments_failed_attempts_and_suspends_after_5(): void
    {
        $user = User::factory()->create([
            'email' => 'lock@example.com',
            'password' => Hash::make('CorrectPass123'),
            'estado_cuenta' => 'activa',
        ]);

        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/auth/login', [
                'email' => $user->email,
                'password' => 'WrongPass123',
            ])->assertStatus(401);
        }

        $user->refresh();
        $this->assertSame('suspendida', $user->estado_cuenta);
        $this->assertGreaterThanOrEqual(5, $user->intentos_fallidos_consecutivos);
    }
}
