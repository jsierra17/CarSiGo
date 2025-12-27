<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Conductor;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Admin
        $admin = User::updateOrCreate(
            ['email' => 'admin@carsigo.co'],
            [
                'name' => 'José Sierra (Admin)',
                'password' => Hash::make('Admin@123'),
                'tipo_usuario' => 'admin',
                'estado_cuenta' => 'activa',
                'telefono' => '3012345678',
                'numero_documento' => '1234567890',
                'tipo_documento' => 'cedula',
                'ciudad' => 'El Carmen de Bolívar',
                'departamento' => 'Bolívar',
                'pais' => 'Colombia',
                'email_verificado' => true,
                'telefono_verificado' => true,
                'recibir_notificaciones' => true,
                'recibir_promociones' => false,
            ]
        );
        $this->command->info('Admin user created: admin@carsigo.co');

        // Soporte técnico
        $soporte = User::updateOrCreate(
            ['email' => 'soporte@carsigo.co'],
            [
                'name' => 'Equipo de Soporte',
                'password' => Hash::make('Soporte@123'),
                'tipo_usuario' => 'soporte',
                'estado_cuenta' => 'activa',
                'telefono' => '3012345679',
                'numero_documento' => '1234567891',
                'tipo_documento' => 'cedula',
                'ciudad' => 'El Carmen de Bolívar',
                'departamento' => 'Bolívar',
                'pais' => 'Colombia',
                'email_verificado' => true,
                'telefono_verificado' => true,
                'recibir_notificaciones' => true,
                'recibir_promociones' => false,
            ]
        );
        $this->command->info('Support user created: soporte@carsigo.co');

        // Conductor 1
        $conductor1 = User::updateOrCreate(
            ['email' => 'conductor1@carsigo.co'],
            [
                'name' => 'Carlos García',
                'password' => Hash::make('Conductor@123'),
                'tipo_usuario' => 'conductor',
                'estado_cuenta' => 'activa',
                'telefono' => '3012345680',
                'numero_documento' => '1234567892',
                'tipo_documento' => 'cedula',
                'ciudad' => 'El Carmen de Bolívar',
                'departamento' => 'Bolívar',
                'pais' => 'Colombia',
                'email_verificado' => true,
                'telefono_verificado' => true,
                'genero' => 'masculino',
                'foto_perfil_url' => 'https://via.placeholder.com/150',
                'recibir_notificaciones' => true,
                'recibir_promociones' => true,
            ]
        );

        // Crear perfil de conductor
        Conductor::updateOrCreate(
            ['usuario_id' => $conductor1->id],
            [
                'numero_licencia' => 'L-1234567890',
                'tipo_licencia' => 'C',
                'fecha_vencimiento_licencia' => now()->addYears(5),
                'estado' => 'activo',
                'documentos_verificados' => true,
                'antecedentes_limpios' => true,
                'fecha_ultima_verificacion' => now(),
                'calificacion_promedio' => 4.8,
                'total_viajes' => 150,
                'total_calificaciones' => 148,
                'comision_porcentaje' => 5.0,
                'ganancias_totales' => 2500000,
                'saldo_pendiente' => 150000,
                'estado_conexion' => 'en_linea',
                'ultima_conexion' => now(),
                'numero_aseguranza' => 'AS-9876543210',
                'vencimiento_aseguranza' => now()->addYear(),
                'compania_aseguranza' => 'Seguros Colombia',
            ]
        );
        $this->command->info('Conductor 1 created: conductor1@carsigo.co');

        // Conductor 2
        $conductor2 = User::updateOrCreate(
            ['email' => 'conductor2@carsigo.co'],
            [
                'name' => 'María López',
                'password' => Hash::make('Conductor@123'),
                'tipo_usuario' => 'conductor',
                'estado_cuenta' => 'activa',
                'telefono' => '3012345681',
                'numero_documento' => '1234567893',
                'tipo_documento' => 'cedula',
                'ciudad' => 'El Carmen de Bolívar',
                'departamento' => 'Bolívar',
                'pais' => 'Colombia',
                'email_verificado' => true,
                'telefono_verificado' => true,
                'genero' => 'femenino',
                'recibir_notificaciones' => true,
                'recibir_promociones' => true,
            ]
        );

        Conductor::updateOrCreate(
            ['usuario_id' => $conductor2->id],
            [
                'numero_licencia' => 'L-1234567891',
                'tipo_licencia' => 'B',
                'fecha_vencimiento_licencia' => now()->addYears(4),
                'estado' => 'activo',
                'documentos_verificados' => true,
                'antecedentes_limpios' => true,
                'fecha_ultima_verificacion' => now(),
                'calificacion_promedio' => 4.5,
                'total_viajes' => 75,
                'total_calificaciones' => 72,
                'comision_porcentaje' => 5.0,
                'ganancias_totales' => 1200000,
                'saldo_pendiente' => 75000,
                'estado_conexion' => 'fuera_linea',
                'ultima_conexion' => now()->subHours(2),
                'numero_aseguranza' => 'AS-9876543211',
                'vencimiento_aseguranza' => now()->addMonths(6),
                'compania_aseguranza' => 'Seguros Bolívar',
            ]
        );
        $this->command->info('Conductor 2 created: conductor2@carsigo.co');

        // Pasajero 1
        User::updateOrCreate(
            ['email' => 'pasajero1@carsigo.co'],
            [
                'name' => 'Juan Martínez',
                'password' => Hash::make('Pasajero@123'),
                'tipo_usuario' => 'pasajero',
                'estado_cuenta' => 'activa',
                'telefono' => '3012345682',
                'numero_documento' => '1234567894',
                'tipo_documento' => 'cedula',
                'ciudad' => 'El Carmen de Bolívar',
                'departamento' => 'Bolívar',
                'pais' => 'Colombia',
                'email_verificado' => true,
                'telefono_verificado' => true,
                'genero' => 'masculino',
                'recibir_notificaciones' => true,
                'recibir_promociones' => true,
            ]
        );
        $this->command->info('Pasajero 1 created: pasajero1@carsigo.co');

        // Pasajero 2
        User::updateOrCreate(
            ['email' => 'pasajero2@carsigo.co'],
            [
                'name' => 'Ana Rodríguez',
                'password' => Hash::make('Pasajero@123'),
                'tipo_usuario' => 'pasajero',
                'estado_cuenta' => 'activa',
                'telefono' => '3012345683',
                'numero_documento' => '1234567895',
                'tipo_documento' => 'cedula',
                'ciudad' => 'El Carmen de Bolívar',
                'departamento' => 'Bolívar',
                'pais' => 'Colombia',
                'email_verificado' => true,
                'telefono_verificado' => true,
                'genero' => 'femenino',
                'recibir_notificaciones' => true,
                'recibir_promociones' => false,
            ]
        );
        $this->command->info('Pasajero 2 created: pasajero2@carsigo.co');

        $this->command->info('Todos los usuarios de prueba han sido creados exitosamente');
    }
}
