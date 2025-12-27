<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Viaje;

class ViajePolicy
{
    /**
     * Ver lista de viajes (admin y soporte)
     */
    public function viewAny(User $user): bool
    {
        return $user->tipo_usuario === 'admin' || $user->tipo_usuario === 'soporte';
    }

    /**
     * Ver detalles de un viaje
     */
    public function view(User $user, Viaje $viaje): bool
    {
        // El pasajero puede ver sus propios viajes
        if ($user->id === $viaje->pasajero_id && $user->tipo_usuario === 'pasajero') {
            return true;
        }

        // El conductor puede ver sus propios viajes
        if ($user->conductor && $user->conductor->id === $viaje->conductor_id && $user->tipo_usuario === 'conductor') {
            return true;
        }

        // Admin y soporte pueden ver todo
        return $user->tipo_usuario === 'admin' || $user->tipo_usuario === 'soporte';
    }

    /**
     * Crear un nuevo viaje (pasajeros)
     */
    public function create(User $user): bool
    {
        // Solo pasajeros activos pueden solicitar viajes
        return $user->tipo_usuario === 'pasajero' && $user->estado_cuenta === 'activa';
    }

    /**
     * Actualizar un viaje
     */
    public function update(User $user, Viaje $viaje): bool
    {
        // El pasajero puede actualizar solo sus viajes no iniciados
        if ($user->id === $viaje->pasajero_id && in_array($viaje->estado, ['solicitado'])) {
            return true;
        }

        // Admin puede actualizar
        return $user->tipo_usuario === 'admin';
    }

    /**
     * Cancelar un viaje
     */
    public function cancelar(User $user, Viaje $viaje): bool
    {
        // El pasajero puede cancelar solo antes de que inicie
        if ($user->id === $viaje->pasajero_id && in_array($viaje->estado, ['solicitado', 'asignado'])) {
            return true;
        }

        // El conductor puede cancelar
        if ($user->conductor && $user->conductor->id === $viaje->conductor_id && in_array($viaje->estado, ['asignado', 'conductor_en_ruta'])) {
            return true;
        }

        // Admin puede cancelar
        return $user->tipo_usuario === 'admin';
    }

    /**
     * Aceptar un viaje (conductores)
     */
    public function aceptar(User $user, Viaje $viaje): bool
    {
        // Solo conductores activos pueden aceptar viajes
        return $user->conductor && 
               $user->conductor->estado === 'activo' && 
               $viaje->estado === 'solicitado';
    }

    /**
     * Completar un viaje
     */
    public function completar(User $user, Viaje $viaje): bool
    {
        // El conductor puede completar sus viajes
        if ($user->conductor && $user->conductor->id === $viaje->conductor_id && $viaje->estado === 'en_progreso') {
            return true;
        }

        // Admin puede completar
        return $user->tipo_usuario === 'admin';
    }

    /**
     * Calificar un viaje
     */
    public function calificar(User $user, Viaje $viaje): bool
    {
        // Pasajero puede calificar después de completado
        if ($user->id === $viaje->pasajero_id && $viaje->estado === 'completado') {
            return true;
        }

        // Conductor puede calificar después de completado
        if ($user->conductor && $user->conductor->id === $viaje->conductor_id && $viaje->estado === 'completado') {
            return true;
        }

        return false;
    }

    /**
     * Ver historial de ubicaciones
     */
    public function verHistorialUbicaciones(User $user, Viaje $viaje): bool
    {
        // Pasajero puede ver ubicaciones de su viaje
        if ($user->id === $viaje->pasajero_id) {
            return true;
        }

        // Conductor puede ver ubicaciones de su viaje
        if ($user->conductor && $user->conductor->id === $viaje->conductor_id) {
            return true;
        }

        // Admin y soporte
        return $user->tipo_usuario === 'admin' || $user->tipo_usuario === 'soporte';
    }
}
