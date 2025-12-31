<?php

namespace App\Http\Controllers\Api;

use App\Models\Pago;
use App\Models\Viaje;
use App\Models\Comision;
use App\Models\Conductor;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class PagoController
{
    /**
     * Listar pagos del usuario
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Pago::query();

        if ($user->tipo_usuario === 'pasajero') {
            $query->where('pasajero_id', $user->id);
        } elseif ($user->conductor) {
            $query->where('conductor_id', $user->conductor->id);
        } elseif (!in_array($user->tipo_usuario, ['admin', 'soporte'])) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        $pagos = $query->with(['viaje:id,origen_direccion,destino_direccion,precio_total'])
            ->orderBy('fecha_solicitud', 'desc')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $pagos,
        ], 200);
    }

    /**
     * Ver detalles de un pago
     */
    public function show(Request $request, Pago $pago): JsonResponse
    {
        $user = $request->user();

        // Verificar autorización
        if ($user->tipo_usuario === 'pasajero' && $pago->pasajero_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        if ($user->conductor && $pago->conductor_id !== $user->conductor->id) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        $pago->load('viaje:id,origen_direccion,destino_direccion,hora_finalizacion');

        return response()->json([
            'success' => true,
            'data' => $pago,
        ], 200);
    }

    /**
     * Procesar pago post-viaje
     */
    public function procesarViaje(Request $request, Viaje $viaje): JsonResponse
    {
        // Solo para viajes completados
        if ($viaje->estado !== 'completado') {
            return response()->json([
                'success' => false,
                'message' => 'El viaje debe estar completado',
            ], 400);
        }

        // Verificar si ya existe pago
        $pagoExistente = Pago::where('viaje_id', $viaje->id)->first();
        if ($pagoExistente) {
            return response()->json([
                'success' => false,
                'message' => 'Este viaje ya tiene un pago registrado',
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'metodo_pago' => 'required|in:efectivo,tarjeta_credito,tarjeta_debito,billetera_digital,transferencia_bancaria,nequi,daviplata',
            'comision_porcentaje' => 'sometimes|numeric|min:0|max:100',
            'requiere_factura' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            DB::beginTransaction();

            // Calcular montos
            $monto_subtotal = $viaje->precio_total ?? ($viaje->tarifa_base + ($viaje->distancia_estimada ?? 0) * 800);
            $impuesto = round($monto_subtotal * 0.08, 2); // 8% IVA
            $descuento = 0; // Implementar promociones
            $monto_total = $monto_subtotal + $impuesto - $descuento;

            // Comisión configurable (por defecto 10%)
            $comision_porcentaje = $request->comision_porcentaje ?? 10.0;
            $comision_plataforma = round($monto_total * ($comision_porcentaje / 100), 2);
            $monto_conductor = $monto_total - $comision_plataforma;

            // Crear pago
            $pago = Pago::create([
                'viaje_id' => $viaje->id,
                'pasajero_id' => $viaje->pasajero_id,
                'conductor_id' => $viaje->conductor_id,
                'monto_subtotal' => $monto_subtotal,
                'impuesto' => $impuesto,
                'descuento' => $descuento,
                'monto_total' => $monto_total,
                'comision_plataforma' => $comision_plataforma,
                'monto_conductor' => $monto_conductor,
                'metodo_pago' => $request->metodo_pago,
                'estado' => 'procesando',
                'numero_transaccion' => 'TRX-' . uniqid(),
                'fecha_solicitud' => now(),
                'requiere_factura' => $request->requiere_factura ?? false,
            ]);

            // Crear comisión para conductor
            Comision::create([
                'conductor_id' => $viaje->conductor_id,
                'pago_id' => $pago->id,
                'monto_viaje' => $monto_total,
                'porcentaje_comision' => $comision_porcentaje,
                'monto_comision' => $comision_plataforma,
                'monto_neto_conductor' => $monto_conductor,
                'fecha_comisión' => now()->toDateString(),
                'estado' => 'pendiente',
            ]);

            // Aplicar comisión a billetera SOLO si el pago fue en efectivo (modelo prepago)
            if ($request->metodo_pago === 'efectivo') {
                $conductor = $viaje->conductor;
                if ($conductor && $conductor->wallet) {
                    $conductor->wallet->aplicarComision(
                        $monto_total,
                        $comision_porcentaje,
                        "Comisión viaje #{$viaje->id}"
                    );
                    
                    // Actualizar balance
                    $conductor->wallet->actualizarBalance();
                }
            }

            // Simular procesamiento (en producción, integrar con gateway de pago)
            $pago->update([
                'estado' => 'completado',
                'fecha_procesamiento' => now(),
                'fecha_completacion' => now(),
            ]);

            // Actualizar ganancias del conductor
            $conductor = $viaje->conductor;
            Conductor::whereKey($conductor->id)->update([
                'ganancias_totales' => DB::raw('ganancias_totales + ' . $monto_conductor),
                'saldo_pendiente' => DB::raw('saldo_pendiente + ' . $monto_conductor),
                'total_viajes' => DB::raw('total_viajes + 1'),
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Pago procesado exitosamente',
                'data' => $pago->load('viaje:id,origen_direccion,destino_direccion'),
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Error al procesar pago: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Reembolsar pago (solo admin)
     */
    public function reembolsar(Request $request, Pago $pago): JsonResponse
    {
        $user = $request->user();

        if ($user->tipo_usuario !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Solo administradores pueden reembolsar',
            ], 403);
        }

        if ($pago->estado !== 'completado') {
            return response()->json([
                'success' => false,
                'message' => 'Solo se pueden reembolsar pagos completados',
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'razon' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            DB::beginTransaction();

            $pago->update([
                'estado' => 'reembolsado',
                'fecha_completacion' => now(),
                'notas' => 'Reembolso: ' . $request->razon,
            ]);

            // Descontar de ganancias del conductor
            $conductor = $pago->conductor;
            Conductor::whereKey($conductor->id)->update([
                'ganancias_totales' => DB::raw('ganancias_totales - ' . $pago->monto_conductor),
                'saldo_pendiente' => DB::raw('saldo_pendiente - ' . $pago->monto_conductor),
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Pago reembolsado exitosamente',
                'data' => $pago,
            ], 200);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Error al reembolsar: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener resumen de ganancias (para conductores)
     */
    public function resumenGanancias(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->conductor) {
            return response()->json([
                'success' => false,
                'message' => 'No eres un conductor',
            ], 403);
        }

        $estadisticas = [
            'ganancias_totales' => $user->conductor->ganancias_totales,
            'saldo_pendiente' => $user->conductor->saldo_pendiente,
            'total_viajes' => $user->conductor->total_viajes,
            'calificacion_promedio' => $user->conductor->calificacion_promedio,
            'ganancias_hoy' => Pago::where('conductor_id', $user->conductor->id)
                ->where('fecha_completacion', '>=', now()->startOfDay())
                ->sum('monto_conductor'),
            'ganancias_mes' => Pago::where('conductor_id', $user->conductor->id)
                ->where('fecha_completacion', '>=', now()->startOfMonth())
                ->sum('monto_conductor'),
        ];

        return response()->json([
            'success' => true,
            'data' => $estadisticas,
        ], 200);
    }

    /**
     * Obtener recibo/comprobante
     */
    public function recibo(Request $request, Pago $pago): JsonResponse
    {
        $user = $request->user();

        // Verificar autorización
        if ($user->tipo_usuario === 'pasajero' && $pago->pasajero_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'No autorizado',
            ], 403);
        }

        $pago->load('viaje:id,origen_direccion,destino_direccion,distancia_estimada,duracion_estimada,hora_finalizacion');

        // Formato de recibo
        $recibo = [
            'numero_transaccion' => $pago->numero_transaccion,
            'fecha' => $pago->fecha_completacion,
            'tipo_viaje' => $pago->viaje->tipo ?? 'Estándar',
            'origen' => $pago->viaje->origen_direccion,
            'destino' => $pago->viaje->destino_direccion,
            'distancia' => $pago->viaje->distancia_estimada . ' km',
            'duracion' => round($pago->viaje->duracion_estimada / 60) . ' minutos',
            'desglose' => [
                'subtotal' => $pago->monto_subtotal,
                'impuesto' => $pago->impuesto,
                'descuento' => $pago->descuento,
                'total' => $pago->monto_total,
            ],
            'metodo_pago' => $pago->metodo_pago,
            'estado' => $pago->estado,
        ];

        return response()->json([
            'success' => true,
            'data' => $recibo,
        ], 200);
    }
}
