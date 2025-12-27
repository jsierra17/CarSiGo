<?php

namespace App\Policies;

use App\Models\User;

class ConductorPolicy
{
    /**
     * Ver lista de conductores (solo admin)
     */
    public function viewAny(User $user): bool
    {
        return $user->tipo_usuario === 'admin' || $user->tipo_usuario === 'soporte';
    }

    /**
     * Ver detalles de un conductor
     */
    public function view(User $user, ?User $conductor = null): bool
    {
        // El conductor puede ver su propia información
        if ($user->id === $conductor?->conductor?->usuario_id) {
            return true;
        }

        // Pasajero puede ver información básica del conductor
        if ($user->tipo_usuario === 'pasajero') {
            return true;
        }

        // Admin y soporte pueden ver todo
        return $user->tipo_usuario === 'admin' || $user->tipo_usuario === 'soporte';
    }

    /**
     * Crear un nuevo conductor (registro)
     */
    public function create(User $user): bool
    {
        // Cualquier usuario puede registrarse como conductor
        return true;
    }

    /**
     * Actualizar datos del conductor
     */
    public function update(User $user, ?User $conductor = null): bool
    {
        // El conductor puede actualizar sus propios datos
        if ($user->id === $conductor?->conductor?->usuario_id) {
            return true;
        }

        // Admin puede actualizar cualquier conductor
        return $user->tipo_usuario === 'admin';
    }

    /**
     * Eliminar un conductor
     */
    public function delete(User $user, ?User $conductor = null): bool
    {
        // Solo admin puede eliminar conductores
        return $user->tipo_usuario === 'admin';
    }

    /**
     * Ver documentos del conductor
     */
    public function viewDocumentos(User $user, ?User $conductor = null): bool
    {
        // El conductor puede ver sus propios documentos
        if ($user->id === $conductor?->conductor?->usuario_id) {
            return true;
        }

        // Admin y soporte pueden ver documentos
        return $user->tipo_usuario === 'admin' || $user->tipo_usuario === 'soporte';
    }

    /**
     * Cambiar estado del conductor (activo/suspendido)
     */
    public function cambiarEstado(User $user): bool
    {
        return $user->tipo_usuario === 'admin';
    }

    /**
     * Ver ganancias y comisiones
     */
    public function verGanancias(User $user, ?User $conductor = null): bool
    {
        // El conductor puede ver sus propias ganancias
        if ($user->id === $conductor?->conductor?->usuario_id) {
            return true;
        }

        // Admin y soporte pueden ver ganancias
        return $user->tipo_usuario === 'admin' || $user->tipo_usuario === 'soporte';
    }
}
