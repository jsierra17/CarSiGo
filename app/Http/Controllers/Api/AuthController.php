<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use App\Models\Conductor;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController
{
    /**
     * Registrar un nuevo usuario
     */
    public function registro(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'tipo_usuario' => 'required|in:pasajero,conductor',
            'telefono' => 'required|string|unique:users',
            'numero_documento' => 'required|string|unique:users',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // Crear el usuario
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'tipo_usuario' => $request->tipo_usuario,
                'telefono' => $request->telefono,
                'numero_documento' => $request->numero_documento,
                'tipo_documento' => $request->tipo_documento ?? 'cedula',
                'ciudad' => $request->ciudad ?? 'El Carmen de Bolívar',
                'departamento' => $request->departamento ?? 'Bolívar',
                'pais' => $request->pais ?? 'Colombia',
                'estado_cuenta' => 'verificacion', // Requiere verificación
                'recibir_notificaciones' => true,
                'recibir_promociones' => true,
            ]);

            // Si es conductor, crear registro de conductor
            if ($request->tipo_usuario === 'conductor') {
                Conductor::create([
                    'usuario_id' => $user->id,
                    'numero_licencia' => $request->numero_licencia,
                    'tipo_licencia' => $request->tipo_licencia ?? 'B',
                    'fecha_vencimiento_licencia' => $request->fecha_vencimiento_licencia,
                    'estado' => 'verificacion',
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Usuario registrado exitosamente. Por favor, verifica tu email.',
                'user' => $user->only(['id', 'name', 'email', 'tipo_usuario', 'estado_cuenta']),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al registrar: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Login del usuario
     */
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // Buscar el usuario
            $user = User::where('email', $request->email)->first();

            if (!$user || !Hash::check($request->password, $user->password)) {
                // Registrar intento fallido
                if ($user) {
                    $user->increment('intentos_fallidos_consecutivos');
                    $user->update(['ultimo_intento_fallido' => now()]);

                    // Bloquear después de 5 intentos
                    if ($user->intentos_fallidos_consecutivos >= 5) {
                        $user->update(['estado_cuenta' => 'suspendida']);
                    }
                }

                return response()->json([
                    'success' => false,
                    'message' => 'Credenciales inválidas',
                ], 401);
            }

            // Verificar estado de la cuenta
            if ($user->estado_cuenta !== 'activa') {
                return response()->json([
                    'success' => false,
                    'message' => 'Tu cuenta está ' . $user->estado_cuenta,
                    'estado_cuenta' => $user->estado_cuenta,
                ], 403);
            }

            // Resetear intentos fallidos
            $user->update([
                'intentos_fallidos_consecutivos' => 0,
                'ultima_sesion_exitosa' => now(),
            ]);

            // Generar token
            $token = $user->createToken('api_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Login exitoso',
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'tipo_usuario' => $user->tipo_usuario,
                    'telefono' => $user->telefono,
                    'ciudad' => $user->ciudad,
                    'foto_perfil_url' => $user->foto_perfil_url,
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error en login: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Logout del usuario
     */
    public function logout(Request $request): JsonResponse
    {
        try {
            // Eliminar todos los tokens del usuario
            $request->user()->tokens()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Logout exitoso',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al cerrar sesión: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener perfil del usuario autenticado
     */
    public function perfil(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'tipo_usuario' => $user->tipo_usuario,
                'estado_cuenta' => $user->estado_cuenta,
                'telefono' => $user->telefono,
                'numero_documento' => $user->numero_documento,
                'tipo_documento' => $user->tipo_documento,
                'ciudad' => $user->ciudad,
                'departamento' => $user->departamento,
                'direccion' => $user->direccion,
                'foto_perfil_url' => $user->foto_perfil_url,
                'bio' => $user->bio,
                'email_verificado' => $user->email_verificado,
                'telefono_verificado' => $user->telefono_verificado,
                'genero' => $user->genero,
                'fecha_nacimiento' => $user->fecha_nacimiento,
                'recibir_notificaciones' => $user->recibir_notificaciones,
                'recibir_promociones' => $user->recibir_promociones,
            ],
        ], 200);
    }

    /**
     * Actualizar perfil del usuario
     */
    public function actualizarPerfil(Request $request): JsonResponse
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'telefono' => 'sometimes|string|unique:users,telefono,' . $user->id,
            'ciudad' => 'sometimes|string',
            'departamento' => 'sometimes|string',
            'direccion' => 'sometimes|string',
            'bio' => 'sometimes|string|max:500',
            'genero' => 'sometimes|in:masculino,femenino,otro,prefiero_no_decir',
            'fecha_nacimiento' => 'sometimes|date',
            'foto_perfil_url' => 'sometimes|url',
            'recibir_notificaciones' => 'sometimes|boolean',
            'recibir_promociones' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $user->update($request->only([
                'name',
                'telefono',
                'ciudad',
                'departamento',
                'direccion',
                'bio',
                'genero',
                'fecha_nacimiento',
                'foto_perfil_url',
                'recibir_notificaciones',
                'recibir_promociones',
            ]));

            return response()->json([
                'success' => true,
                'message' => 'Perfil actualizado exitosamente',
                'user' => $user->only([
                    'id', 'name', 'email', 'telefono', 'ciudad', 'bio', 'foto_perfil_url'
                ]),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar perfil: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Cambiar contraseña
     */
    public function cambiarPassword(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'password_actual' => 'required|string',
            'password_nueva' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        // Verificar contraseña actual
        if (!Hash::check($request->password_actual, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Contraseña actual incorrecta',
            ], 401);
        }

        try {
            $user->update([
                'password' => Hash::make($request->password_nueva),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Contraseña actualizada exitosamente',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al cambiar contraseña: ' . $e->getMessage(),
            ], 500);
        }
    }
}
