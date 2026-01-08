/// Representa el estado de un viaje.
enum RideStatus {
  requested,   // El pasajero ha solicitado un viaje
  accepted,    // Un conductor ha aceptado el viaje
  inProgress,  // El viaje está en curso
  completed,   // El viaje ha finalizado con éxito
  cancelled,   // El viaje fue cancelado
}

class Ride {
  final String id;
  final String passengerId;
  final String? driverId;
  final RideStatus status;
  final String? pickupLocationName;
  final String? destinationLocationName;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final double? fare;
  final DateTime createdAt;

  Ride({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.status,
    this.pickupLocationName,
    this.destinationLocationName,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.fare,
    required this.createdAt,
  });

  /// Crea un objeto [Ride] desde un mapa (ej. desde Supabase).
  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id'] as String,
      passengerId: map['passenger_id'] as String,
      driverId: map['driver_id'] as String?,
      status: RideStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (map['status'] as String).toLowerCase(),
        orElse: () => RideStatus.cancelled, // Estado por defecto en caso de error
      ),
      pickupLocationName: map['pickup_location_name'] as String?,
      destinationLocationName: map['destination_location_name'] as String?,
      pickupLatitude: map['pickup_latitude'] as double?,
      pickupLongitude: map['pickup_longitude'] as double?,
      destinationLatitude: map['destination_latitude'] as double?,
      destinationLongitude: map['destination_longitude'] as double?,
      fare: (map['fare'] as num?)?.toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convierte el objeto [Ride] a un mapa para ser enviado a Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'status': status.name,
      'pickup_location_name': pickupLocationName,
      'destination_location_name': destinationLocationName,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'fare': fare,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
