<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserRole
{
    /**
     * Middleware para verificar que el usuario tiene uno de los roles especificados
     * Uso: Route::middleware('role:admin,soporte')->group(...)
     */
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }

        // Verificar si el usuario tiene uno de los roles permitidos
        if (!in_array($user->tipo_usuario, $roles)) {
            return response()->json([
                'message' => 'Unauthorized. Required role(s): ' . implode(', ', $roles),
                'user_role' => $user->tipo_usuario,
            ], 403);
        }

        return $next($request);
    }
}
