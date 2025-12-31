import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/viaje_provider.dart';
import '../router/app_router.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final viajeProvider = context.read<ViajeProvider>();
    final authProvider = context.read<AuthProvider>();

    // Load user trips
    await viajeProvider.getViajesUsuario();
    
    // If user is a driver, also load available trips
    if (authProvider.isConductor) {
      await viajeProvider.getViajesDisponibles();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Viajes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Activos'),
            Tab(text: 'Historial'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => AppRouter.goToRequestTrip(context),
            tooltip: 'Solicitar Viaje',
          ),
        ],
      ),
      body: Consumer2<AuthProvider, ViajeProvider>(
        builder: (context, authProvider, viajeProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Active Trips Tab
              _buildActiveTripsTab(authProvider, viajeProvider),
              
              // History Tab
              _buildHistoryTab(viajeProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveTripsTab(AuthProvider authProvider, ViajeProvider viajeProvider) {
    if (viajeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viajeProvider.hasViajeActivo) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current Active Trip
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Viaje Actual',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTripDetails(viajeProvider.viajeActual!),
                    const SizedBox(height: 16),
                    _buildTripActions(viajeProvider.viajeActual!, authProvider, viajeProvider),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Available trips for drivers
    if (authProvider.isConductor && viajeProvider.viajesDisponibles.isNotEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Viajes Disponibles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: viajeProvider.viajesDisponibles.length,
              itemBuilder: (context, index) {
                final viaje = viajeProvider.viajesDisponibles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Viaje #${viaje.id}'),
                    subtitle: Text('${viaje.origenDireccion} → ${viaje.destinoDireccion}'),
                    trailing: viaje.precioTotal != null
                        ? Text('\$${viaje.precioTotal!.toStringAsFixed(0)}')
                        : null,
                    onTap: () => AppRouter.goToTripDetails(context, viaje.id),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // No active trips
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes viajes activos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            authProvider.isPasajero
                ? 'Solicita un nuevo viaje para comenzar'
                : 'Espera a que haya viajes disponibles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          if (authProvider.isPasajero) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => AppRouter.goToRequestTrip(context),
              child: const Text('Solicitar Viaje'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ViajeProvider viajeProvider) {
    if (viajeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final completedTrips = viajeProvider.viajesCompletados;
    final cancelledTrips = viajeProvider.viajesCancelados;

    if (completedTrips.isEmpty && cancelledTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes viajes en el historial',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: completedTrips.length + cancelledTrips.length,
      itemBuilder: (context, index) {
        final trip = index < completedTrips.length
            ? completedTrips[index]
            : cancelledTrips[index - completedTrips.length];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: trip.isCompletado
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Icon(
                trip.isCompletado ? Icons.check : Icons.cancel,
                color: trip.isCompletado ? Colors.green : Colors.red,
              ),
            ),
            title: Text('Viaje #${trip.id}'),
            subtitle: Text('${trip.origenDireccion} → ${trip.destinoDireccion}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (trip.precioTotal != null)
                  Text(
                    '\$${trip.precioTotal!.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  trip.fechaSolicitud != null
                      ? _formatDate(trip.fechaSolicitud!)
                      : '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            onTap: () => AppRouter.goToTripDetails(context, trip.id),
          ),
        );
      },
    );
  }

  Widget _buildTripDetails(dynamic viaje) {
    return Column(
      children: [
        _buildLocationRow(
          icon: Icons.circle,
          color: Colors.green,
          label: 'Origen',
          address: viaje.origenDireccion,
        ),
        const SizedBox(height: 12),
        _buildLocationRow(
          icon: Icons.place,
          color: Colors.red,
          label: 'Destino',
          address: viaje.destinoDireccion,
        ),
        if (viaje.precioTotal != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Precio: \$${viaje.precioTotal!.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Estado: ${_getEstadoText(viaje.estado)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getEstadoColor(viaje.estado),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color color,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                address,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripActions(dynamic viaje, AuthProvider authProvider, ViajeProvider viajeProvider) {
    switch (viaje.estado) {
      case 'solicitado':
        if (authProvider.isConductor) {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await viajeProvider.aceptarViaje(viaje.id);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Viaje aceptado')),
                      );
                    }
                  },
                  child: const Text('Aceptar Viaje'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final success = await viajeProvider.cancelarViaje(viaje.id);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Viaje cancelado')),
                      );
                    }
                  },
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          );
        } else {
          return OutlinedButton(
            onPressed: () async {
              final success = await viajeProvider.cancelarViaje(viaje.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Viaje cancelado')),
                );
              }
            },
            child: const Text('Cancelar Viaje'),
          );
        }
      
      case 'asignado':
        if (authProvider.isConductor) {
          return ElevatedButton(
            onPressed: () async {
              final success = await viajeProvider.iniciarViaje(viaje.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Viaje iniciado')),
                );
              }
            },
            child: const Text('Iniciar Viaje'),
          );
        } else {
          return const Text('Esperando que el conductor inicie el viaje...');
        }
      
      case 'en_progreso':
        if (authProvider.isConductor) {
          return ElevatedButton(
            onPressed: () async {
              final success = await viajeProvider.completarViaje(viaje.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Viaje completado')),
                );
              }
            },
            child: const Text('Completar Viaje'),
          );
        } else {
          return const Text('Viaje en progreso...');
        }
      
      default:
        return const SizedBox.shrink();
    }
  }

  String _getEstadoText(String estado) {
    switch (estado) {
      case 'solicitado':
        return 'Solicitado';
      case 'asignado':
        return 'Asignado';
      case 'en_progreso':
        return 'En Progreso';
      case 'completado':
        return 'Completado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'solicitado':
        return Colors.orange;
      case 'asignado':
        return Colors.blue;
      case 'en_progreso':
        return Colors.purple;
      case 'completado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
