@extends('layouts.app')

@section('content')
<div id="wallet-app" class="container mx-auto p-6">
    <h1 class="text-2xl font-bold mb-4">Billetera - Prueba Frontend</h1>

    <div class="mb-4">
        <label class="block font-medium">Bearer token (Conductor)</label>
        <input id="wallet-token" class="border p-2 w-full" placeholder="Pegue aquí el token de conductor" />
    </div>

    <div class="grid grid-cols-2 gap-4 mb-6">
        <div class="p-4 border rounded">
            <h2 class="font-semibold">Balance</h2>
            <p id="wallet-balance" class="text-lg">Cargando...</p>
            <p id="wallet-status" class="text-sm text-gray-600"></p>
        </div>
        <div class="p-4 border rounded">
            <h2 class="font-semibold">Acciones</h2>
            <button id="wallet-refresh" class="bg-blue-600 text-white py-2 px-4 rounded">Refrescar</button>
        </div>
    </div>

    <div class="mb-6">
        <h3 class="font-semibold mb-2">Recargar saldo (simulación)</h3>
        <form id="wallet-recarga-form" class="grid grid-cols-3 gap-2">
            <input name="amount" placeholder="Monto (ej: 5000)" class="border p-2" />
            <input name="reference" placeholder="Referencia" class="border p-2" />
            <button class="bg-green-600 text-white p-2 rounded">Recargar</button>
        </form>
    </div>

    <div>
        <h3 class="font-semibold mb-2">Historial</h3>
        <ul id="wallet-history" class="list-disc pl-6 text-sm text-gray-700">Cargando...</ul>
    </div>
</div>
@endsection
