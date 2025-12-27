<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Viaje;

// Bloquear wallet del conductor1
$u = User::where('email','conductor1@carsigo.co')->first();
if($u && $u->conductor && $u->conductor->wallet){
    $u->conductor->wallet->update(['status' => 'blocked']);
    echo "WALLET_BLOCKED\n";
} else {
    echo "NO_WALLET\n";
}

// Buscar pasajero
$pas = User::where('tipo_usuario','pasajero')->first();
if(!$pas){
    echo "NO_PASAJERO\n";
    exit(0);
}

// Crear viaje de prueba
$viaje = Viaje::create([
    'pasajero_id' => $pas->id,
    'origen_latitud' => -34.6037,
    'origen_longitud' => -58.3816,
    'origen_direccion' => 'Origen Test',
    'origen_lugar' => 'Origen Test Place',
    'destino_latitud' => -34.5997,
    'destino_longitud' => -58.3820,
    'destino_direccion' => 'Destino Test',
    'destino_lugar' => 'Destino Test Place',
    'tipo' => 'estandar',
    'pasajeros_solicitados' => 1,
    'tarifa_base' => 2500,
    'estado' => 'solicitado',
    'hora_solicitud' => now(),
]);

echo "VIAJE_ID:" . $viaje->id . "\n";
