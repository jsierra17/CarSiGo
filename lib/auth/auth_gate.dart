import 'package:carsigo/auth/login_page.dart';
import 'package:carsigo/home/passenger_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// El nuevo AuthGate, ahora escuchando a Firebase
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Si todavía está esperando, muestra un spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Si hay un usuario, significa que ha iniciado sesión
        if (snapshot.hasData) {
          // TODO: En el futuro, aquí irá la lógica para diferenciar
          // entre conductor y pasajero, leyendo desde nuestra base de datos.
          // Por ahora, siempre lo llevamos a la Home del Pasajero.
          return const PassengerHomePage();
        } else {
          // Si no hay datos (no hay usuario), muestra la página de login
          return const LoginPage();
        }
      },
    );
  }
}
