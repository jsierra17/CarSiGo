import 'package:carsigo/auth/auth_gate.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _navigateToAuth(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isWideScreen = MediaQuery.of(context).size.width > 500;

    // --- Colores Corporativos ---
    const Color colorRojo = Color(0xFFE53935);
    const Color colorVerde = Color(0xFF43A047);
    const Color colorGrisClaro = Color(0xFFF5F5F5);
    const Color colorTextoPrincipal = Color(0xFF212121);
    const Color colorTextoSecundario = Color(0xFF757575);

    return Scaffold(
      backgroundColor: colorGrisClaro,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450), // Evita que se estire en pantallas anchas
          child: ListView(
            shrinkWrap: true, // Centra el contenido verticalmente
            padding: const EdgeInsets.all(24.0),
            children: [
              // --- Logo ---
              // TODO: Reemplaza este Icon por tu widget de Logo (ej. Image.asset('assets/logo.png'))
              const Icon(Icons.directions_car_filled, size: 60, color: colorTextoPrincipal),
              const SizedBox(height: 30),

              // --- Ilustración Central ---
              SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 120, color: Colors.grey[300]),
                    Icon(Icons.location_on, size: 70, color: colorRojo),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- Mensaje Principal ---
              Text(
                'Muévete fácil, seguro y rápido',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorTextoPrincipal,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Conecta pasajeros y conductores en segundos con tarifas justas.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(color: colorTextoSecundario, height: 1.5),
              ),
              const SizedBox(height: 40),

              // --- Botones CTA ---
              ElevatedButton(
                onPressed: () => _navigateToAuth(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorRojo,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isWideScreen ? 20 : 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('Solicitar un viaje', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _navigateToAuth(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorVerde,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isWideScreen ? 20 : 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('Soy conductor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 24),

              // --- Acciones Secundarias ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => _navigateToAuth(context),
                    child: const Text('Iniciar sesión', style: TextStyle(color: colorTextoSecundario)),
                  ),
                  const Text('·', style: TextStyle(color: colorTextoSecundario)),
                  TextButton(
                    onPressed: () { /* TODO: Implementar soporte */ },
                    child: const Text('Soporte', style: TextStyle(color: colorTextoSecundario)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
