# CarSiGo Flutter App

Aplicación móvil de CarSiGo - Plataforma inteligente de transporte.

## Características

- 🚗 **Solicitud de Viajes**: Solicita viajes de forma rápida y sencilla
- 📍 **Gestión de Ubicaciones**: Guarda tus lugares favoritos
- 👤 **Autenticación Segura**: Login y registro con diferentes tipos de usuario
- 📱 **Interfaz Moderna**: Diseño intuitivo con Material Design 3
- 🗺️ **Integración con Mapas**: Ubicación en tiempo real
- 💳 **Múltiples Métodos de Pago**: Efectivo, Wompi, Wallet
- 🎫 **Soporte Integrado**: Sistema de tickets de soporte

## Arquitectura

La aplicación sigue una arquitectura limpia con las siguientes capas:

```
lib/
├── app/                    # Configuración de la aplicación
├── core/                   # Servicios y configuración central
│   ├── config/            # Configuración de la app
│   └── services/          # Servicios (API, Auth, Location)
├── data/                  # Capa de datos
│   ├── models/            # Modelos de datos
│   └── repositories/      # Repositorios
├── presentation/          # Capa de presentación
│   ├── providers/         # State management (Provider)
│   ├── router/           # Navegación (GoRouter)
│   └── screens/          # Pantallas de la UI
└── assets/               # Recursos estáticos
```

## Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo móvil
- **Provider**: State management
- **GoRouter**: Navegación declarativa
- **Dio**: Cliente HTTP
- **Geolocator**: Servicios de ubicación
- **Google Maps**: Integración con mapas
- **Shared Preferences**: Almacenamiento local
- **Google Fonts**: Tipografías personalizadas

## Requisitos

- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- Android SDK (para desarrollo Android)
- Xcode (para desarrollo iOS)

## Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/carsigo_flutter.git
cd carsigo_flutter
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Configura las variables de entorno:
```bash
cp .env.example .env
# Edita .env con tus configuraciones
```

4. Ejecuta la aplicación:
```bash
flutter run
```

## Configuración

### API Configuration

Edita `lib/core/config/app_config.dart` para configurar:

- URL base de la API
- Timeouts de conexión
- Claves de almacenamiento local
- Configuración de mapas

### Environment Variables

Crea un archivo `.env` en la raíz del proyecto:

```env
API_BASE_URL=http://localhost:8000/api
MAPS_API_KEY=tu_google_maps_api_key
```

## Estructura de Pantallas

### Autenticación
- `SplashScreen`: Pantalla de bienvenida
- `LoginScreen`: Inicio de sesión
- `RegisterScreen`: Registro de usuarios
- `ForgotPasswordScreen`: Recuperación de contraseña

### Navegación Principal
- `MainScreen`: Contenedor con navegación inferior
- `HomeScreen`: Inicio con acciones rápidas
- `TripScreen`: Gestión de viajes activos e historial
- `ProfileScreen`: Perfil de usuario y configuración

### Viajes
- `RequestTripScreen`: Solicitud de nuevos viajes
- `TripDetailsScreen`: Detalles de un viaje específico
- `TripHistoryScreen`: Historial completo de viajes

### Ubicaciones
- `SavedLocationsScreen`: Lugares guardados
- `AddLocationScreen`: Agregar/editar ubicaciones

### Perfil y Soporte
- `EditProfileScreen`: Editar información personal
- `ChangePasswordScreen`: Cambiar contraseña
- `SupportScreen`: Centro de soporte
- `CreateTicketScreen`: Crear ticket de soporte

## State Management

La aplicación utiliza **Provider** para el manejo de estado:

- `AuthProvider`: Gestión de autenticación y usuario
- `ViajeProvider`: Gestión de viajes y solicitudes
- `UbicacionProvider`: Gestión de ubicaciones y GPS

## Navegación

Se utiliza **GoRouter** para una navegación tipo declarativa:

```dart
// Ejemplos de navegación
AppRouter.goToLogin(context);
AppRouter.goToMain(context);
AppRouter.goToRequestTrip(context);
```

## Modelos de Datos

### User
Información del usuario con validaciones y getters convenientes.

### Viaje
Modelo de viaje con estados y métodos para gestión del ciclo de vida.

### Ubicacion
Modelo de ubicación con coordenadas y metadatos.

## Servicios

### ApiService
Cliente HTTP con interceptores para logging y manejo de errores.

### AuthService
Gestión de autenticación, login, registro y persistencia.

### LocationService
Servicios de geolocalización y conversión de direcciones.

## Testing

Ejecuta los tests con:

```bash
flutter test
```

## Build

Para generar el APK de producción:

```bash
flutter build apk --release
```

Para generar el bundle de Android:

```bash
flutter build appbundle --release
```

Para iOS:

```bash
flutter build ios --release
```

## Contribución

1. Fork el proyecto
2. Crea una feature branch (`git checkout -b feature/amazing-feature`)
3. Commit tus cambios (`git commit -m 'Add some amazing feature'`)
4. Push a la branch (`git push origin feature/amazing-feature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Soporte

Para reportar issues o solicitar features, por favor abre un issue en el repositorio de GitHub.

---

**Desarrollado con ❤️ para CarSiGo**
