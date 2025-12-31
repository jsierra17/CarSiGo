import 'package:equatable/equatable.dart';

class Ubicacion extends Equatable {
  final int id;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String tipo;
  final String? descripcion;
  final int? usuarioId;
  final bool esFavorita;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Ubicacion({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.tipo,
    this.descripcion,
    this.usuarioId,
    this.esFavorita = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      tipo: json['tipo'] as String,
      descripcion: json['descripcion'] as String?,
      usuarioId: json['usuario_id'] as int?,
      esFavorita: json['es_favorita'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'tipo': tipo,
      'descripcion': descripcion,
      'usuario_id': usuarioId,
      'es_favorita': esFavorita,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Ubicacion copyWith({
    int? id,
    String? nombre,
    String? direccion,
    double? latitud,
    double? longitud,
    String? tipo,
    String? descripcion,
    int? usuarioId,
    bool? esFavorita,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ubicacion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      usuarioId: usuarioId ?? this.usuarioId,
      esFavorita: esFavorita ?? this.esFavorita,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters for convenience
  bool get isCasa => tipo.toLowerCase() == 'casa';
  bool get isTrabajo => tipo.toLowerCase() == 'trabajo';
  bool get isOtro => tipo.toLowerCase() == 'otro';
  bool get isFavorita => esFavorita;

  @override
  List<Object?> get props => [
        id,
        nombre,
        direccion,
        latitud,
        longitud,
        tipo,
        descripcion,
        usuarioId,
        esFavorita,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Ubicacion(id: $id, nombre: $nombre, direccion: $direccion, tipo: $tipo)';
  }
}
