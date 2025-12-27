<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Pago;

class PagoPolicy
{
    /**
     * Ver lista de pagos (admin, soporte)
     */
    public function viewAny(User $user): bool
    {
        return $user->tipo_usuario === 'admin' || $user->tipo_usuario === 'soporte';
    }

    /**
     * Ver detalles de un pago
     */
    public function view(User $user, Pago $pago): bool
    {
        // El pasajero puede ver pagos de sus viajes
        if ($user->id === $pago->pasajero_id && $user->tipo_usuario === 'pasajero') {
            return true;
        }

        // El conductor puede ver sus propios pagos
        if ($user->conductor && $user->conductor->id === $pago->conductor_id) {
            return true;
        }

        // Admin y soporte
        return $user->tipo_usuario === 'admin' || $user->tipo_usuario === 'soporte';
    }

    /**
     * Procesar un pago
     */
    public function procesar(User $user): bool
    {
        // Solo admin puede procesar pagos manualmente
        return $user->tipo_usuario === 'admin';
    }

    /**
     * Reembolsar un pago
     */
    public function reembolsar(User $user): bool
    {
        return $user->tipo_usuario === 'admin';
    }

    /**
     * Ver recibos/comprobantes
     */
    public function verRecibos(User $user, Pago $pago): bool
    {
        // El pasajero puede ver recibos de sus pagos
        if ($user->id === $pago->pasajero_id) {
            return true;
        }

        // El conductor puede ver recibos
        if ($user->conductor && $user->conductor->id === $pago->conductor_id) {
            return true;
        }

        // Admin y soporte
        return $user->tipo_usuario === 'admin' || $user->tipo_usuario === 'soporte';
    }
}
