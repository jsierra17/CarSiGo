<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAccountActive
{
    /**
     * Middleware para verificar que la cuenta del usuario esté activa
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }

        if ($user->estado_cuenta !== 'activa') {
            return response()->json([
                'message' => 'Your account is ' . $user->estado_cuenta,
                'estado_cuenta' => $user->estado_cuenta,
            ], 403);
        }

        return $next($request);
    }
}
