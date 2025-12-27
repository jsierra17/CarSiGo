#!/bin/bash

# Script de prueba para APIs de autenticación CarSiGo
# Uso: bash test-auth.sh

BASE_URL="http://localhost:8000/api"

echo "======================================"
echo "🔐 Pruebas de Autenticación CarSiGo"
echo "======================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. TEST LOGIN ADMIN
echo -e "${YELLOW}1. Login como Admin${NC}"
ADMIN_LOGIN=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@carsigo.co",
    "password": "Admin@123"
  }')

echo "$ADMIN_LOGIN" | jq '.'
ADMIN_TOKEN=$(echo "$ADMIN_LOGIN" | jq -r '.token')
echo -e "${GREEN}Token Admin: $ADMIN_TOKEN${NC}"
echo ""

# 2. TEST LOGIN CONDUCTOR
echo -e "${YELLOW}2. Login como Conductor${NC}"
CONDUCTOR_LOGIN=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "conductor1@carsigo.co",
    "password": "Conductor@123"
  }')

echo "$CONDUCTOR_LOGIN" | jq '.'
CONDUCTOR_TOKEN=$(echo "$CONDUCTOR_LOGIN" | jq -r '.token')
echo -e "${GREEN}Token Conductor: $CONDUCTOR_TOKEN${NC}"
echo ""

# 3. TEST LOGIN PASAJERO
echo -e "${YELLOW}3. Login como Pasajero${NC}"
PASAJERO_LOGIN=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "pasajero1@carsigo.co",
    "password": "Pasajero@123"
  }')

echo "$PASAJERO_LOGIN" | jq '.'
PASAJERO_TOKEN=$(echo "$PASAJERO_LOGIN" | jq -r '.token')
echo -e "${GREEN}Token Pasajero: $PASAJERO_TOKEN${NC}"
echo ""

# 4. TEST OBTENER PERFIL (Admin)
echo -e "${YELLOW}4. Obtener perfil del Admin${NC}"
curl -s -X GET "$BASE_URL/auth/perfil" \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'
echo ""

# 5. TEST OBTENER PERFIL (Conductor)
echo -e "${YELLOW}5. Obtener perfil del Conductor${NC}"
curl -s -X GET "$BASE_URL/auth/perfil" \
  -H "Authorization: Bearer $CONDUCTOR_TOKEN" | jq '.'
echo ""

# 6. TEST ACTUALIZAR PERFIL
echo -e "${YELLOW}6. Actualizar perfil del Conductor${NC}"
curl -s -X PUT "$BASE_URL/auth/perfil" \
  -H "Authorization: Bearer $CONDUCTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bio": "Conductor experimentado con 150 viajes",
    "ciudad": "Cartagena"
  }' | jq '.'
echo ""

# 7. TEST REGISTRO NUEVO USUARIO
echo -e "${YELLOW}7. Registrar nuevo usuario${NC}"
curl -s -X POST "$BASE_URL/auth/registro" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Carlos Nuevo",
    "email": "carlos.nuevo@example.com",
    "password": "Password@123",
    "password_confirmation": "Password@123",
    "tipo_usuario": "pasajero",
    "telefono": "3009999999",
    "numero_documento": "9876543210",
    "tipo_documento": "cedula",
    "ciudad": "El Carmen de Bolívar",
    "departamento": "Bolívar",
    "pais": "Colombia"
  }' | jq '.'
echo ""

# 8. TEST CAMBIAR CONTRASEÑA
echo -e "${YELLOW}8. Cambiar contraseña del Conductor${NC}"
curl -s -X POST "$BASE_URL/auth/cambiar-password" \
  -H "Authorization: Bearer $CONDUCTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "password_actual": "Conductor@123",
    "password_nueva": "NuevaPassword@123",
    "password_nueva_confirmation": "NuevaPassword@123"
  }' | jq '.'
echo ""

# 9. TEST LOGOUT
echo -e "${YELLOW}9. Logout del Conductor${NC}"
curl -s -X POST "$BASE_URL/auth/logout" \
  -H "Authorization: Bearer $CONDUCTOR_TOKEN" | jq '.'
echo ""

# 10. TEST ACCESO DENEGADO (Token inválido después de logout)
echo -e "${YELLOW}10. Intento de acceso con token después de logout${NC}"
curl -s -X GET "$BASE_URL/auth/perfil" \
  -H "Authorization: Bearer $CONDUCTOR_TOKEN" | jq '.'
echo ""

echo -e "${GREEN}======================================"
echo "✅ Pruebas completadas"
echo "======================================${NC}"
