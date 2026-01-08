import 'package:carsigo/auth/login_page.dart';
import 'package:carsigo/core/supabase_client.dart';
import 'package:carsigo/drivers/driver_service.dart';
import 'package:carsigo/home/home_page.dart';
import 'package:carsigo/home/passenger_home_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  /// Un widget de destino opcional. Si se proporciona, el AuthGate intentará
  /// navegar a esta página después de una autenticación exitosa.
  final Widget? destination;

  const AuthGate({super.key, this.destination});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        if (session != null) {
          // Si el usuario ya está autenticado

          // Si se especificó un destino (ej. CreateDriverProfilePage), vamos allí.
          if (destination != null) {
            // Usamos un Future para navegar después de que el frame se construya
            Future.microtask(() => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => destination!),
            ));
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // Lógica estándar: verificar si es conductor o pasajero
          return FutureBuilder(
            future: DriverService().getDriverProfile(session.user.id),
            builder: (context, driverSnapshot) {
              if (driverSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (driverSnapshot.hasData && driverSnapshot.data != null) {
                return const HomePage(); // Es conductor, va a la home del conductor
              } else {
                return const PassengerHomePage(); // Es pasajero, va a la home del pasajero
              }
            },
          );
        } else {
          // Si no hay sesión, siempre vamos a la página de login.
          return const LoginPage();
        }
      },
    );
  }
}
