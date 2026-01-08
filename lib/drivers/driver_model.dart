/// Representa el estado actual de un conductor.
enum DriverStatus {
  offline, // El conductor no está disponible
  online,  // El conductor está disponible para recibir viajes
  inRide,  // El conductor está actualmente en un viaje
  blocked, // El conductor ha sido bloqueado
}

/// Modelo de datos para un conductor de CarSiGo.
class Driver {
  final String id;
  final String userId; 
  final String fullName;
  final String idNumber; // Nuevo campo para la cédula o identificación
  final String vehicleModel;
  final String licensePlate;
  final DriverStatus status;
  final DateTime createdAt;

  Driver({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.idNumber, // Requerido en el constructor
    required this.vehicleModel,
    required this.licensePlate,
    required this.status,
    required this.createdAt,
  });

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      fullName: map['full_name'] as String,
      idNumber: map['id_number'] as String? ?? '', // Maneja casos donde el campo puede ser nulo en la BD
      vehicleModel: map['vehicle_model'] as String,
      licensePlate: map['license_plate'] as String,
      status: DriverStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (map['status'] as String).toLowerCase(),
        orElse: () => DriverStatus.offline,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'id_number': idNumber,
      'vehicle_model': vehicleModel,
      'license_plate': licensePlate,
      'status': status.name,
    };
  }
}
