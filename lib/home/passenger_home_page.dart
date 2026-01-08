import 'package:carsigo/auth/auth_gate.dart';
import 'package:carsigo/drivers/create_driver_profile_page.dart';
import 'package:flutter/material.dart';

class PassengerHomePage extends StatefulWidget {
  const PassengerHomePage({super.key});

  @override
  State<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends State<PassengerHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showAuthFlow() {
    // Cuando el usuario quiere ver viajes, lo llevamos al flujo de autenticación normal.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  void _navigateToBecomeDriver() {
    // Cuando quiere ser conductor, llevamos al AuthGate, pero le decimos
    // que el destino final, después del login, es la página de creación de perfil.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AuthGate(destination: CreateDriverProfilePage())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildAppDrawer(),
      body: Stack(
        children: [
          // Placeholder del Mapa
          Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.map_outlined, size: 150, color: Colors.white))),
          
          // AppBar con botón de menú
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Card(
                elevation: 4,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias, // Asegura que el InkWell no se salga del círculo
                child: InkWell(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.menu, size: 24, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),

          // Hoja inferior deslizable
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Invitado'), 
            accountEmail: Text('Inicia sesión para empezar'),
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40)),
            decoration: BoxDecoration(color: Color(0xFFE53935)),
          ),
          ListTile(
            leading: const Icon(Icons.drive_eta),
            title: const Text('Conviértete en Conductor'),
            onTap: _navigateToBecomeDriver,
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Mis Viajes'),
            onTap: () => _showAuthFlow(), // Requiere login
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () => _showAuthFlow(), // Requiere login
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre nosotros'),
            onTap: () { /* TODO: Navegar a página web informativa */ },
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35, minChildSize: 0.1, maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Card(
          elevation: 12.0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          margin: EdgeInsets.zero,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20.0),
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 24),
              const Text('¿Listo para tu próximo viaje?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(readOnly: true, decoration: InputDecoration(prefixIcon: const Icon(Icons.my_location, color: Colors.green), hintText: 'Mi ubicación actual', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[100])),
              const SizedBox(height: 12),
              TextField(readOnly: true, decoration: InputDecoration(prefixIcon: const Icon(Icons.location_on, color: Colors.red), hintText: 'Elige tu destino', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[100])),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showAuthFlow,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Ver opciones de viaje', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      },
    );
  }
}
