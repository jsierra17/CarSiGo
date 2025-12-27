<?php

namespace App\Http\Controllers\Api;

use App\Models\Conductor;
use App\Models\Wallet;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class WalletController
{
    /**
     * Obtener balance actual del conductor
     */
    public function balance(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor) {
            return response()->json([
                'success' => false,
                'message' => 'No eres conductor',
            ], 403);
        }

        $wallet = $user->conductor->wallet;

        if (!$wallet) {
            return response()->json([
                'success' => false,
                'message' => 'No tienes billetera',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'balance' => $wallet->balance,
                'status' => $wallet->status,
                'limite_negativo' => $wallet->limite_negativo,
                'puede_aceptar_viajes' => $wallet->puedeAceptarViajes(),
            ],
        ], 200);
    }

    /**
     * Historial de transacciones
     */
    public function historial(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor) {
            return response()->json([
                'success' => false,
                'message' => 'No eres conductor',
            ], 403);
        }

        $wallet = $user->conductor->wallet;

        if (!$wallet) {
            return response()->json([
                'success' => false,
                'message' => 'No tienes billetera',
            ], 404);
        }

        $transacciones = $wallet->transactions()
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $transacciones,
        ], 200);
    }

    /**
     * Recargar saldo (prepago)
     * En producción se integraría con Wompi
     */
    public function recargar(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor) {
            return response()->json([
                'success' => false,
                'message' => 'No eres conductor',
            ], 403);
        }

        $validated = $request->validate([
            'monto' => 'required|numeric|min:1000|max:5000000',
            'metodo' => 'required|in:tarjeta,nequi,daviplata,pse',
        ]);

        $wallet = $user->conductor->wallet;

        if (!$wallet) {
            return response()->json([
                'success' => false,
                'message' => 'No tienes billetera',
            ], 404);
        }

        try {
            // En producción: integrar con Wompi
            // Por ahora: crear transacción pendiente
            $transaccion = $wallet->transactions()->create([
                'type' => 'credit',
                'amount' => $validated['monto'],
                'description' => "Recarga de saldo - {$validated['metodo']}",
                'reference' => 'RECARGA-' . uniqid(),
                'status' => 'pending',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Recarga iniciada. Esperando confirmación de pago.',
                'data' => [
                    'transaction_id' => $transaccion->id,
                    'monto' => $validated['monto'],
                    'status' => $transaccion->status,
                    'metodo' => $validated['metodo'],
                    'url_pago' => 'https://wompi.com.co/pagar/' . $transaccion->reference,
                ],
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al procesar recarga: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Confirmar recarga (webhook de Wompi)
     */
    public function confirmarRecarga(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'reference' => 'required|string|exists:transactions,reference',
            'status' => 'required|in:completed,failed',
        ]);

        try {
            $transaccion = Transaction::where('reference', $validated['reference'])->firstOrFail();

            if ($transaccion->status !== 'pending') {
                return response()->json([
                    'success' => false,
                    'message' => 'Transacción ya procesada',
                ], 400);
            }

            $transaccion->update(['status' => $validated['status']]);

            // Actualizar balance
            $wallet = $transaccion->wallet;
            $wallet->actualizarBalance();

            return response()->json([
                'success' => true,
                'message' => 'Recarga ' . ($validated['status'] === 'completed' ? 'confirmada' : 'fallida'),
                'data' => [
                    'balance' => $wallet->balance,
                    'status' => $wallet->status,
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Resumen financiero del conductor
     */
    public function resumen(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor) {
            return response()->json([
                'success' => false,
                'message' => 'No eres conductor',
            ], 403);
        }

        $wallet = $user->conductor->wallet;

        if (!$wallet) {
            return response()->json([
                'success' => false,
                'message' => 'No tienes billetera',
            ], 404);
        }

        // Estadísticas
        $ganancias = $wallet->transactions()
            ->where('type', 'credit')
            ->where('status', 'completed')
            ->sum('amount');

        $comisiones = $wallet->transactions()
            ->where('type', 'debit')
            ->where('status', 'completed')
            ->sum('amount');

        $recargas_pendientes = $wallet->transactions()
            ->where('type', 'credit')
            ->where('status', 'pending')
            ->sum('amount');

        return response()->json([
            'success' => true,
            'data' => [
                'balance_actual' => $wallet->balance,
                'estado' => $wallet->status,
                'ganancias_totales' => $ganancias,
                'comisiones_totales' => $comisiones,
                'recargas_pendientes' => $recargas_pendientes,
                'limite_negativo' => $wallet->limite_negativo,
                'puede_aceptar_viajes' => $wallet->puedeAceptarViajes(),
            ],
        ], 200);
    }
}
