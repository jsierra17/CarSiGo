class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://192.168.20.43:8080/api'; // Tu IP local
  static const String wsUrl = 'ws://192.168.20.43:8081'; // WebSocket URL
  static const String appName = 'CarSiGo';
  static const String appVersion = '1.0.0';
  
  // Timeout Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userTypeKey = 'user_type';
  static const String userProfileKey = 'user_profile';
  static const String fcmTokenKey = 'fcm_token';
  
  // Map Configuration
  static const double defaultMapZoom = 15.0;
  static const double searchRadius = 5.0; // km
  
  // Location Configuration
  static const Duration locationUpdateInterval = Duration(seconds: 10);
  static const double locationAccuracyThreshold = 100.0; // meters
  
  // UI Configuration
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  
  // Business Rules
  static const int maxPassengersPerTrip = 6;
  static const int minPasswordLength = 8;
  static const double walletNegativeLimit = -5000.0; // COP
  
  // Payment Methods
  static const List<String> paymentMethods = [
    'efectivo',
    'wompi',
    'wallet',
  ];
  
  // Trip Types
  static const List<String> tripTypes = [
    'estandar',
    'compartido',
    'urgente',
  ];
  
  // User Types
  static const List<String> userTypes = [
    'pasajero',
    'conductor',
    'admin',
    'soporte',
  ];
  
  // Account States
  static const List<String> accountStates = [
    'activa',
    'suspendida',
    'verificacion',
  ];
  
  // Trip States
  static const List<String> tripStates = [
    'solicitado',
    'asignado',
    'en_progreso',
    'completado',
    'cancelado',
  ];
  
  // Payment States
  static const List<String> paymentStates = [
    'pendiente',
    'procesando',
    'completado',
    'reembolsado',
  ];
  
  // Support Categories
  static const List<String> supportCategories = [
    'viaje',
    'pago',
    'conductor',
    'pasajero',
    'vehiculo',
    'app',
    'otro',
  ];
  
  // Support Priorities
  static const List<String> supportPriorities = [
    'baja',
    'media',
    'alta',
    'critica',
  ];
  
  // Support Ticket States
  static const List<String> supportTicketStates = [
    'abierto',
    'en_progreso',
    'esperando_usuario',
    'resuelto',
    'cerrado',
  ];

  // WebSocket Configuration
  static const String pusherKey = 'reverb_key';
  static const String pusherCluster = 'mt1';
  static const String pusherHost = '192.168.20.43';
  static const int pusherPort = 8080;
  static const String pusherScheme = 'http';
}
