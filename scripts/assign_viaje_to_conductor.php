<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Viaje;

// Asignar viaje ID 1 al conductor1 y poner estado 'asignado'
$u = User::where('email','conductor1@carsigo.co')->first();
$viaje = Viaje::find(1);
if(!$u || !$u->conductor){
    echo "NO_CONDUCTOR\n";
    exit(0);
}
if(!$viaje){
    echo "NO_VIAJE\n";
    exit(0);
}
$viaje->update([
    'conductor_id' => $u->conductor->id,
    'estado' => 'asignado',
    'hora_asignacion' => now(),
]);

echo "VIAJE_ASIGNADO: {$viaje->id} -> CONDUCTOR: {$u->conductor->id}\n";
