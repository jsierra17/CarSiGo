import 'package:equatable/equatable.dart';

class Viaje extends Equatable {
  final int id;
  final int pasajeroId;
  final int? conductorId;
  final String estado;
  final String origenDireccion;
  final String destinoDireccion;
  final double origenLatitud;
  final double origenLongitud;
  final double destinoLatitud;
  final double destinoLongitud;
  final String? tipo;
  final double? precioTotal;
  final DateTime? fechaSolicitud;
  final DateTime? createdAt;

  const Viaje({
    required this.id,
    required this.pasajeroId,
    this.conductorId,
    required this.estado,
    required this.origenDireccion,
    required this.destinoDireccion,
    required this.origenLatitud,
    required this.origenLongitud,
    required this.destinoLatitud,
    required this.destinoLongitud,
    this.tipo,
    this.precioTotal,
    this.fechaSolicitud,
    this.createdAt,
  });

  factory Viaje.fromJson(Map<String, dynamic> json) {
    return Viaje(
      id: json['id'] as int,
      pasajeroId: json['pasajero_id'] as int,
      conductorId: json['conductor_id'] as int?,
      estado: json['estado'] as String,
      origenDireccion: json['origen_direccion'] as String,
      destinoDireccion: json['destino_direccion'] as String,
      origenLatitud: (json['origen_latitud'] as num).toDouble(),
      origenLongitud: (json['origen_longitud'] as num).toDouble(),
      destinoLatitud: (json['destino_latitud'] as num).toDouble(),
      destinoLongitud: (json['destino_longitud'] as num).toDouble(),
      tipo: json['tipo'] as String?,
      precioTotal: json['precio_total'] != null
          ? (json['precio_total'] as num).toDouble()
          : null,
      fechaSolicitud: json['fecha_solicitud'] != null
          ? DateTime.parse(json['fecha_solicitud'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pasajero_id': pasajeroId,
      'conductor_id': conductorId,
      'estado': estado,
      'origen_direccion': origenDireccion,
      'destino_direccion': destinoDireccion,
      'origen_latitud': origenLatitud,
      'origen_longitud': origenLongitud,
      'destino_latitud': destinoLatitud,
      'destino_longitud': destinoLongitud,
      'tipo': tipo,
      'precio_total': precioTotal,
      'fecha_solicitud': fechaSolicitud?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Viaje copyWith({
    int? id,
    int? pasajeroId,
    int? conductorId,
    String? estado,
    String? origenDireccion,
    String? destinoDireccion,
    double? origenLatitud,
    double? origenLongitud,
    double? destinoLatitud,
    double? destinoLongitud,
    String? tipo,
    double? precioTotal,
    DateTime? fechaSolicitud,
    DateTime? createdAt,
  }) {
    return Viaje(
      id: id ?? this.id,
      pasajeroId: pasajeroId ?? this.pasajeroId,
      conductorId: conductorId ?? this.conductorId,
      estado: estado ?? this.estado,
      origenDireccion: origenDireccion ?? this.origenDireccion,
      destinoDireccion: destinoDireccion ?? this.destinoDireccion,
      origenLatitud: origenLatitud ?? this.origenLatitud,
      origenLongitud: origenLongitud ?? this.origenLongitud,
      destinoLatitud: destinoLatitud ?? this.destinoLatitud,
      destinoLongitud: destinoLongitud ?? this.destinoLongitud,
      tipo: tipo ?? this.tipo,
      precioTotal: precioTotal ?? this.precioTotal,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Getters for convenience
  bool get isSolicitado => estado == 'solicitado';
  bool get isAsignado => estado == 'asignado';
  bool get isEnProgreso => estado == 'en_progreso';
  bool get isCompletado => estado == 'completado';
  bool get isCancelado => estado == 'cancelado';
  bool get hasConductor => conductorId != null;
  bool get hasPrecio => precioTotal != null && precioTotal! > 0;

  @override
  List<Object?> get props => [
        id,
        pasajeroId,
        conductorId,
        estado,
        origenDireccion,
        destinoDireccion,
        origenLatitud,
        origenLongitud,
        destinoLatitud,
        destinoLongitud,
        tipo,
        precioTotal,
        fechaSolicitud,
        createdAt,
      ];

  @override
  String toString() {
    return 'Viaje(id: $id, estado: $estado, origen: $origenDireccion, destino: $destinoDireccion)';
  }
}
