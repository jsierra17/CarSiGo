<?php

namespace Database\Seeders;

use App\Models\Configuracion;
use Illuminate\Database\Seeder;

class ConfiguracionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $configs = [
            // Precios y tarifas
            [
                'clave' => 'tarifa_base',
                'valor' => '2500',
                'tipo_dato' => 'decimal',
                'categoria' => 'precios',
                'descripcion' => 'Tarifa base en pesos colombianos',
                'grupo' => 'tarifas',
                'editable' => true,
            ],
            [
                'clave' => 'precio_por_km',
                'valor' => '800',
                'tipo_dato' => 'decimal',
                'categoria' => 'precios',
                'descripcion' => 'Precio por kilómetro recorrido',
                'grupo' => 'tarifas',
                'editable' => true,
            ],
            [
                'clave' => 'precio_por_minuto',
                'valor' => '50',
                'tipo_dato' => 'decimal',
                'categoria' => 'precios',
                'descripcion' => 'Precio por minuto en espera',
                'grupo' => 'tarifas',
                'editable' => true,
            ],
            [
                'clave' => 'precio_tarifa_premium',
                'valor' => '1.5',
                'tipo_dato' => 'decimal',
                'categoria' => 'precios',
                'descripcion' => 'Multiplicador de tarifa para servicios premium',
                'grupo' => 'tarifas',
                'editable' => true,
            ],
            // Comisiones
            [
                'clave' => 'comision_conductores_porcentaje',
                'valor' => '5.00',
                'tipo_dato' => 'decimal',
                'categoria' => 'comisiones',
                'descripcion' => 'Porcentaje de comisión que retiene la plataforma',
                'grupo' => 'comisiones_conductores',
                'editable' => true,
            ],
            [
                'clave' => 'descuento_referencia',
                'valor' => '5000',
                'tipo_dato' => 'decimal',
                'categoria' => 'comisiones',
                'descripcion' => 'Descuento al nuevo usuario referido',
                'grupo' => 'comisiones_conductores',
                'editable' => true,
            ],
            // Seguridad
            [
                'clave' => 'max_intentos_login',
                'valor' => '5',
                'tipo_dato' => 'integer',
                'categoria' => 'seguridad',
                'descripcion' => 'Máximo de intentos fallidos antes de bloquear',
                'grupo' => 'autenticacion',
                'editable' => true,
            ],
            [
                'clave' => 'tiempo_bloqueo_minutos',
                'valor' => '30',
                'tipo_dato' => 'integer',
                'categoria' => 'seguridad',
                'descripcion' => 'Minutos de bloqueo después de máximos intentos',
                'grupo' => 'autenticacion',
                'editable' => true,
            ],
            [
                'clave' => 'requerir_documento_conductores',
                'valor' => 'true',
                'tipo_dato' => 'boolean',
                'categoria' => 'seguridad',
                'descripcion' => 'Requiere verificación de documento para conductores',
                'grupo' => 'verificacion_usuarios',
                'editable' => true,
            ],
            // Notificaciones
            [
                'clave' => 'notificaciones_push_habilitadas',
                'valor' => 'true',
                'tipo_dato' => 'boolean',
                'categoria' => 'notificaciones',
                'descripcion' => 'Habilitar notificaciones push',
                'grupo' => 'notificaciones',
                'editable' => true,
            ],
            [
                'clave' => 'enviar_email_confirmacion',
                'valor' => 'true',
                'tipo_dato' => 'boolean',
                'categoria' => 'notificaciones',
                'descripcion' => 'Enviar email de confirmación de viaje',
                'grupo' => 'notificaciones',
                'editable' => true,
            ],
            // Límites
            [
                'clave' => 'velocidad_maxima_alerta',
                'valor' => '100',
                'tipo_dato' => 'integer',
                'categoria' => 'limites',
                'descripcion' => 'Velocidad máxima en km/h para alerta',
                'grupo' => 'seguridad_viaje',
                'editable' => true,
            ],
            [
                'clave' => 'radio_busqueda_conductores',
                'valor' => '5',
                'tipo_dato' => 'integer',
                'categoria' => 'limites',
                'descripcion' => 'Radio de búsqueda de conductores en km',
                'grupo' => 'busqueda',
                'editable' => true,
            ],
            // Integraciones
            [
                'clave' => 'google_maps_api_key',
                'valor' => 'AIzaSyDxxx',
                'tipo_dato' => 'string',
                'categoria' => 'integraciones',
                'descripcion' => 'API Key de Google Maps',
                'grupo' => 'apis_externas',
                'editable' => true,
            ],
            [
                'clave' => 'whatsapp_api_url',
                'valor' => 'https://api.whatsapp.com',
                'tipo_dato' => 'string',
                'categoria' => 'integraciones',
                'descripcion' => 'URL de API de WhatsApp',
                'grupo' => 'apis_externas',
                'editable' => true,
            ],
            // General
            [
                'clave' => 'app_nombre',
                'valor' => 'CarSiGo',
                'tipo_dato' => 'string',
                'categoria' => 'general',
                'descripcion' => 'Nombre de la aplicación',
                'grupo' => 'general',
                'editable' => true,
            ],
            [
                'clave' => 'ciudad_principal',
                'valor' => 'El Carmen de Bolívar',
                'tipo_dato' => 'string',
                'categoria' => 'general',
                'descripcion' => 'Ciudad principal de operación',
                'grupo' => 'general',
                'editable' => true,
            ],
        ];

        foreach ($configs as $config) {
            Configuracion::updateOrCreate(
                ['clave' => $config['clave']],
                $config
            );
        }

        $this->command->info('Configuración inicial cargada');
    }
}
