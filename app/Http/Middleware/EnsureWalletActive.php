<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureWalletActive
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user || !$user->conductor) {
            return $next($request);
        }

        $wallet = $user->conductor->wallet;

        if (!$wallet || !$wallet->puedeAceptarViajes()) {
            return response()->json([
                'success' => false,
                'message' => 'Billetera bloqueada. Recarga saldo para continuar.',
                'balance' => $wallet->balance ?? 0,
            ], 403);
        }

        return $next($request);
    }
}
