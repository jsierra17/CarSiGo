import 'package:carsigo/drivers/create_driver_profile_page.dart';
import 'package:carsigo/home/passenger_home_page.dart';
import 'package:flutter/material.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Qué quieres hacer?'),
        automaticallyImplyLeading: false, // Evita que aparezca el botón de regreso
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.drive_eta),
                label: const Text('Quiero ser conductor'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateDriverProfilePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Buscar un viaje'),
                onPressed: () {
                  // Usamos pushReplacement para que el usuario no pueda volver a esta pantalla
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const PassengerHomePage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
