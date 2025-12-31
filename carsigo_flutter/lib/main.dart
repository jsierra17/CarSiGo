import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'core/services/location_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/viaje_repository.dart';
import 'data/repositories/ubicacion_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/viaje_provider.dart';
import 'presentation/providers/ubicacion_provider.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Initialize services
  final apiService = ApiService(AppConfig.apiBaseUrl);
  final authService = AuthService(apiService, sharedPreferences);
  final locationService = LocationService();
  
  // Initialize repositories
  final authRepository = AuthRepository(authService);
  final viajeRepository = ViajeRepository(apiService);
  final ubicacionRepository = UbicacionRepository(apiService);
  
  runApp(
    CarSiGoApp(
      authRepository: authRepository,
      viajeRepository: viajeRepository,
      ubicacionRepository: ubicacionRepository,
      locationService: locationService,
    ),
  );
}

class CarSiGoApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ViajeRepository viajeRepository;
  final UbicacionRepository ubicacionRepository;
  final LocationService locationService;

  const CarSiGoApp({
    super.key,
    required this.authRepository,
    required this.viajeRepository,
    required this.ubicacionRepository,
    required this.locationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ViajeProvider(viajeRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => UbicacionProvider(ubicacionRepository, locationService),
        ),
      ],
      child: MaterialApp.router(
        title: 'CarSiGo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'CO'),
        ],
      ),
    );
  }
}
