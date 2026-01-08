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
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AuthGate()));
  }

  void _navigateToBecomeDriver() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AuthGate(destination: CreateDriverProfilePage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildAppDrawer(),
      body: Stack(
        children: [
          // 1. Fondo de Mapa (Simulado con una imagen)
          // TODO: Asegúrate de tener una imagen en 'assets/images/map_background.png'
          Image.asset(
            'assets/images/map_background.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            // En caso de que la imagen no cargue, muestra un fondo oscuro
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF2c3e50)),
          ),

          // 2. AppBar con botón de menú
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FloatingActionButton(
                mini: true,
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                backgroundColor: Colors.white,
                child: const Icon(Icons.menu, color: Colors.black87),
              ),
            ),
          ),

          // 3. Hoja inferior deslizable
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  Widget _buildAppDrawer() {
    // ... (El código del Drawer no necesita cambios, lo dejamos como está)
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
            onTap: () => _showAuthFlow(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () => _showAuthFlow(),
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
      initialChildSize: 0.4, minChildSize: 0.2, maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black26)],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20.0),
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 24),
              const Text('¿A dónde vamos hoy?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              // --- Campo de Destino ---
              InkWell(
                onTap: _showAuthFlow,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [Icon(Icons.search, color: Colors.black54), SizedBox(width: 12), Text('Elige tu destino', style: TextStyle(fontSize: 16))]),
                ),
              ),
              const SizedBox(height: 20),
              // --- Accesos directos (Casa / Trabajo) ---
              Row(
                children: [
                  _buildShortcut(icon: Icons.home, label: 'Casa'),
                  const SizedBox(width: 16),
                  _buildShortcut(icon: Icons.work, label: 'Trabajo'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShortcut({required IconData icon, required String label}) {
    return Expanded(
      child: InkWell(
        onTap: _showAuthFlow,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.blueGrey), const SizedBox(width: 8), Text(label)]),
        ),
      ),
    );
  }
}
