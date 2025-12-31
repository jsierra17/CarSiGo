<?php

use OpenApi\Annotations as OA;

/**
 * @OA\Info(
 *     title="CarSiGo API",
 *     version="1.0.0",
 *     description="Plataforma inteligente de transporte"
 * )
 * @OA\Get(
 *     path="/api/health",
 *     tags={"Health"},
 *     summary="Health check endpoint",
 *     @OA\Response(
 *         response=200,
 *         description="API is healthy",
 *         @OA\JsonContent(
 *             @OA\Property(property="status", type="string", example="ok")
 *         )
 *     )
 * )
 */
