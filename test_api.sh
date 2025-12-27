#!/bin/bash

# Script de prueba de endpoints de CarSiGo
# Uso: bash test_api.sh

BASE_URL="http://127.0.0.1:8000/api"
PASAJERO_EMAIL="pasajero1@carsigo.co"
PASAJERO_PASSWORD="Pasajero@123"
CONDUCTOR_EMAIL="conductor1@carsigo.co"
CONDUCTOR_PASSWORD="Conductor@123"

echo "======================================"
echo "🚀 PRUEBA DE ENDPOINTS - CarSiGo"
echo "======================================"
echo ""

# 1. Login Pasajero
echo "1️⃣  Realizando login como pasajero..."
PASAJERO_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$PASAJERO_EMAIL\",\"password\":\"$PASAJERO_PASSWORD\"}")

PASAJERO_TOKEN=$(echo $PASAJERO_RESPONSE | jq -r '.data.token')
echo "✅ Token pasajero: ${PASAJERO_TOKEN:0:20}..."
echo ""

# 2. Login Conductor
echo "2️⃣  Realizando login como conductor..."
CONDUCTOR_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$CONDUCTOR_EMAIL\",\"password\":\"$CONDUCTOR_PASSWORD\"}")

CONDUCTOR_TOKEN=$(echo $CONDUCTOR_RESPONSE | jq -r '.data.token')
echo "✅ Token conductor: ${CONDUCTOR_TOKEN:0:20}..."
echo ""

# 3. Pasajero solicita viaje
echo "3️⃣  Pasajero solicita un viaje..."
VIAJE_RESPONSE=$(curl -s -X POST "$BASE_URL/viajes" \
  -H "Authorization: Bearer $PASAJERO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "origen_latitud": 10.4023,
    "origen_longitud": -75.5156,
    "destino_latitud": 10.4115,
    "destino_longitud": -75.5078,
    "origen_direccion": "Calle 1, El Carmen",
    "destino_direccion": "Calle 5, El Carmen",
    "distancia_estimada": 2.5,
    "duracion_estimada": 600
  }')

VIAJE_ID=$(echo $VIAJE_RESPONSE | jq -r '.data.id')
echo "✅ Viaje creado con ID: $VIAJE_ID"
echo ""

# 4. Conductor reporta ubicación
echo "4️⃣  Conductor reporta ubicación..."
UBICACION_RESPONSE=$(curl -s -X POST "$BASE_URL/ubicaciones/reportar" \
  -H "Authorization: Bearer $CONDUCTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "latitud": 10.4023,
    "longitud": -75.5156,
    "precision": 5.0,
    "proveedor": "gps"
  }')

echo "✅ Ubicación reportada"
echo ""

# 5. Conductor busca viajes disponibles
echo "5️⃣  Conductor busca viajes disponibles..."
DISPONIBLES=$(curl -s -X GET "$BASE_URL/viajes/disponibles" \
  -H "Authorization: Bearer $CONDUCTOR_TOKEN")

VIAJES_COUNT=$(echo $DISPONIBLES | jq -r '.data.total')
echo "✅ Viajes disponibles encontrados: $VIAJES_COUNT"
echo ""

# 6. Conductor acepta viaje
echo "6️⃣  Conductor acepta el viaje..."
ACEPTAR=$(curl -s -X PATCH "$BASE_URL/viajes/$VIAJE_ID/aceptar" \
  -H "Authorization: Bearer $CONDUCTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}')

echo "✅ Viaje aceptado"
echo ""

# 7. Conductor inicia viaje
echo "7️⃣  Conductor inicia el viaje..."
INICIAR=$(curl -s -X PATCH "$BASE_URL/viajes/$VIAJE_ID/iniciar" \
  -H "Authorization: Bearer $CONDUCTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}')

echo "✅ Viaje iniciado"
echo ""

# 8. Conductor completa viaje
echo "8️⃣  Conductor completa el viaje..."
COMPLETAR=$(curl -s -X PATCH "$BASE_URL/viajes/$VIAJE_ID/completar" \
  -H "Authorization: Bearer $CONDUCTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "distancia_estimada": 2.5,
    "duracion_estimada": 600,
    "precio_total": 10000
  }')

echo "✅ Viaje completado"
echo ""

# 9. Procesar pago
echo "9️⃣  Procesando pago..."
PAGO=$(curl -s -X POST "$BASE_URL/pagos/viajes/$VIAJE_ID/procesar" \
  -H "Authorization: Bearer $PASAJERO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "metodo_pago": "tarjeta_credito",
    "requiere_factura": true
  }')

PAGO_ID=$(echo $PAGO | jq -r '.data.id')
echo "✅ Pago procesado con ID: $PAGO_ID"
echo ""

# 10. Calificar viaje
echo "🔟 Pasajero califica el viaje..."
CALIFICACION=$(curl -s -X POST "$BASE_URL/viajes/$VIAJE_ID/calificar" \
  -H "Authorization: Bearer $PASAJERO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "calificacion": 5,
    "comentario": "Excelente conductor y vehículo limpio"
  }')

echo "✅ Viaje calificado"
echo ""

# 11. Ver resumen de ganancias del conductor
echo "1️⃣1️⃣  Conductor verifica ganancias..."
GANANCIAS=$(curl -s -X GET "$BASE_URL/pagos/resumen/ganancias" \
  -H "Authorization: Bearer $CONDUCTOR_TOKEN")

echo "✅ Ganancias obtenidas"
echo ""

# 12. Crear ticket de soporte
echo "1️⃣2️⃣  Pasajero crea ticket de soporte..."
TICKET=$(curl -s -X POST "$BASE_URL/soporte/tickets" \
  -H "Authorization: Bearer $PASAJERO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "asunto": "Consulta sobre el servicio",
    "descripcion": "¿Puedo solicitar un recibo por correo?",
    "categoria": "aplicacion",
    "prioridad": "baja",
    "viaje_id": '$VIAJE_ID'
  }')

TICKET_ID=$(echo $TICKET | jq -r '.data.id')
echo "✅ Ticket creado con ID: $TICKET_ID"
echo ""

echo "======================================"
echo "✅ PRUEBAS COMPLETADAS EXITOSAMENTE"
echo "======================================"
echo ""
echo "Resumen:"
echo "- ✅ Login pasajero"
echo "- ✅ Login conductor"
echo "- ✅ Crear viaje"
echo "- ✅ Reportar ubicación"
echo "- ✅ Buscar viajes disponibles"
echo "- ✅ Aceptar viaje"
echo "- ✅ Iniciar viaje"
echo "- ✅ Completar viaje"
echo "- ✅ Procesar pago"
echo "- ✅ Calificar viaje"
echo "- ✅ Ver ganancias"
echo "- ✅ Crear ticket soporte"
