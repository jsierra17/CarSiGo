import 'package:carsigo/core/supabase_client.dart';
import 'package:carsigo/rides/ride_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RideService {
  final String _ridesTable = 'rides';

  /// Crea una nueva solicitud de viaje.
  Future<Ride> createRide(Ride ride) async {
    try {
      final response = await supabase
          .from(_ridesTable)
          .insert(ride.toMap())
          .select()
          .single();

      return Ride.fromMap(response);
    } catch (e) {
      print('Error al crear el viaje: $e');
      rethrow;
    }
  }

  /// Obtiene un stream de los viajes solicitados que aún no han sido aceptados.
  /// Ideal para la pantalla del conductor.
  Stream<List<Ride>> getAvailableRides() {
    return supabase
        .from(_ridesTable)
        .stream(primaryKey: ['id'])
        .eq('status', 'requested')
        .order('created_at', ascending: true)
        .map((maps) => maps.map((map) => Ride.fromMap(map)).toList());
  }

  /// Actualiza el estado de un viaje y asigna un conductor.
  Future<void> acceptRide(String rideId, String driverId) async {
    try {
      await supabase.from(_ridesTable).update({
        'status': 'accepted',
        'driver_id': driverId,
      }).eq('id', rideId);
    } catch (e) {
      print('Error al aceptar el viaje: $e');
      rethrow;
    }
  }

  /// Escucha los cambios de un viaje específico.
  /// Ideal para que el pasajero sepa cuándo un conductor aceptó su viaje.
  Stream<Ride> getRideUpdates(String rideId) {
    return supabase
        .from(_ridesTable)
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .map((maps) => Ride.fromMap(maps.first));
  }
}
