import 'package:carsigo/auth/auth_service.dart';
import 'package:carsigo/core/supabase_client.dart';
import 'package:carsigo/drivers/driver_model.dart';
import 'package:carsigo/drivers/driver_service.dart';
import 'package:carsigo/rides/ride_model.dart';
import 'package:carsigo/rides/ride_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RideService _rideService = RideService();
  final DriverService _driverService = DriverService();
  Driver? _currentDriver;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile();
  }

  Future<void> _fetchDriverProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      final driver = await _driverService.getDriverProfile(userId);
      if (mounted) {
        setState(() {
          _currentDriver = driver;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar perfil del conductor: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptRide(String rideId) async {
    if (_currentDriver == null) return;

    try {
      await _rideService.acceptRide(rideId, _currentDriver!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Viaje aceptado!')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al aceptar el viaje: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentDriver == null
              ? const Center(child: Text('No se pudo cargar el perfil del conductor.'))
              : StreamBuilder<List<Ride>>(
                  stream: _rideService.getAvailableRides(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No hay viajes disponibles en este momento.'),
                      );
                    }

                    final availableRides = snapshot.data!;

                    return ListView.builder(
                      itemCount: availableRides.length,
                      itemBuilder: (context, index) {
                        final ride = availableRides[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text('Viaje a ${ride.destinationLocationName ?? 'Destino no especificado'}'),
                            subtitle: Text('Desde: ${ride.pickupLocationName ?? 'Origen no especificado'}'),
                            trailing: ElevatedButton(
                              onPressed: () => _acceptRide(ride.id),
                              child: const Text('Aceptar'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
