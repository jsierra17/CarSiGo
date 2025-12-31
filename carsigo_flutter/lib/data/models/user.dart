import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String tipoUsuario;
  final String estadoCuenta;
  final String telefono;
  final String ciudad;
  final String? fotoPerfilUrl;
  final String? bio;
  final String? fechaNacimiento;
  final String? numeroDocumento;
  final String? tipoDocumento;
  final String? departamento;
  final String? pais;
  final String? direccion;
  final bool emailVerificado;
  final bool telefonoVerificado;
  final bool recibirNotificaciones;
  final bool recibirPromociones;
  final String? genero;
  final DateTime? ultimoIntentoFallido;
  final DateTime? ultimaSesionExitosa;
  final int intentosFallidosConsecutivos;
  final DateTime? emailVerifiedAt;
  final DateTime? telefonoVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.tipoUsuario,
    required this.estadoCuenta,
    required this.telefono,
    required this.ciudad,
    this.fotoPerfilUrl,
    this.bio,
    this.fechaNacimiento,
    this.numeroDocumento,
    this.tipoDocumento,
    this.departamento,
    this.pais,
    this.direccion,
    this.emailVerificado = false,
    this.telefonoVerificado = false,
    this.recibirNotificaciones = true,
    this.recibirPromociones = true,
    this.genero,
    this.ultimoIntentoFallido,
    this.ultimaSesionExitosa,
    this.intentosFallidosConsecutivos = 0,
    this.emailVerifiedAt,
    this.telefonoVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      tipoUsuario: json['tipo_usuario'] as String,
      estadoCuenta: json['estado_cuenta'] as String? ?? 'verificacion',
      telefono: json['telefono'] as String,
      ciudad: json['ciudad'] as String? ?? '',
      fotoPerfilUrl: json['foto_perfil_url'] as String?,
      bio: json['bio'] as String?,
      fechaNacimiento: json['fecha_nacimiento'] as String?,
      numeroDocumento: json['numero_documento'] as String?,
      tipoDocumento: json['tipo_documento'] as String?,
      departamento: json['departamento'] as String?,
      pais: json['pais'] as String?,
      direccion: json['direccion'] as String?,
      emailVerificado: json['email_verificado'] as bool? ?? false,
      telefonoVerificado: json['telefono_verificado'] as bool? ?? false,
      recibirNotificaciones: json['recibir_notificaciones'] as bool? ?? true,
      recibirPromociones: json['recibir_promociones'] as bool? ?? true,
      genero: json['genero'] as String?,
      ultimoIntentoFallido: json['ultimo_intento_fallido'] != null
          ? DateTime.parse(json['ultimo_intento_fallido'])
          : null,
      ultimaSesionExitosa: json['ultima_sesion_exitosa'] != null
          ? DateTime.parse(json['ultima_sesion_exitosa'])
          : null,
      intentosFallidosConsecutivos:
          json['intentos_fallidos_consecutivos'] as int? ?? 0,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      telefonoVerifiedAt: json['telefono_verified_at'] != null
          ? DateTime.parse(json['telefono_verified_at'])
          : null,
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
      'name': name,
      'email': email,
      'tipo_usuario': tipoUsuario,
      'estado_cuenta': estadoCuenta,
      'telefono': telefono,
      'ciudad': ciudad,
      'foto_perfil_url': fotoPerfilUrl,
      'bio': bio,
      'fecha_nacimiento': fechaNacimiento,
      'numero_documento': numeroDocumento,
      'tipo_documento': tipoDocumento,
      'departamento': departamento,
      'pais': pais,
      'direccion': direccion,
      'email_verificado': emailVerificado,
      'telefono_verificado': telefonoVerificado,
      'recibir_notificaciones': recibirNotificaciones,
      'recibir_promociones': recibirPromociones,
      'genero': genero,
      'ultimo_intento_fallido': ultimoIntentoFallido?.toIso8601String(),
      'ultima_sesion_exitosa': ultimaSesionExitosa?.toIso8601String(),
      'intentos_fallidos_consecutivos': intentosFallidosConsecutivos,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'telefono_verified_at': telefonoVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? tipoUsuario,
    String? estadoCuenta,
    String? telefono,
    String? ciudad,
    String? fotoPerfilUrl,
    String? bio,
    String? fechaNacimiento,
    String? numeroDocumento,
    String? tipoDocumento,
    String? departamento,
    String? pais,
    String? direccion,
    bool? emailVerificado,
    bool? telefonoVerificado,
    bool? recibirNotificaciones,
    bool? recibirPromociones,
    String? genero,
    DateTime? ultimoIntentoFallido,
    DateTime? ultimaSesionExitosa,
    int? intentosFallidosConsecutivos,
    DateTime? emailVerifiedAt,
    DateTime? telefonoVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      estadoCuenta: estadoCuenta ?? this.estadoCuenta,
      telefono: telefono ?? this.telefono,
      ciudad: ciudad ?? this.ciudad,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
      bio: bio ?? this.bio,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      departamento: departamento ?? this.departamento,
      pais: pais ?? this.pais,
      direccion: direccion ?? this.direccion,
      emailVerificado: emailVerificado ?? this.emailVerificado,
      telefonoVerificado: telefonoVerificado ?? this.telefonoVerificado,
      recibirNotificaciones: recibirNotificaciones ?? this.recibirNotificaciones,
      recibirPromociones: recibirPromociones ?? this.recibirPromociones,
      genero: genero ?? this.genero,
      ultimoIntentoFallido: ultimoIntentoFallido ?? this.ultimoIntentoFallido,
      ultimaSesionExitosa: ultimaSesionExitosa ?? this.ultimaSesionExitosa,
      intentosFallidosConsecutivos:
          intentosFallidosConsecutivos ?? this.intentosFallidosConsecutivos,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      telefonoVerifiedAt: telefonoVerifiedAt ?? this.telefonoVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters for convenience
  bool get isPasajero => tipoUsuario == 'pasajero';
  bool get isConductor => tipoUsuario == 'conductor';
  bool get isAdmin => tipoUsuario == 'admin';
  bool get isSoporte => tipoUsuario == 'soporte';
  bool get isAccountActive => estadoCuenta == 'activa';
  bool get isAccountSuspended => estadoCuenta == 'suspendida';
  bool get isAccountVerification => estadoCuenta == 'verificacion';
  bool get hasProfileImage => fotoPerfilUrl != null && fotoPerfilUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        tipoUsuario,
        estadoCuenta,
        telefono,
        ciudad,
        fotoPerfilUrl,
        bio,
        fechaNacimiento,
        numeroDocumento,
        tipoDocumento,
        departamento,
        pais,
        direccion,
        emailVerificado,
        telefonoVerificado,
        recibirNotificaciones,
        recibirPromociones,
        genero,
        ultimoIntentoFallido,
        ultimaSesionExitosa,
        intentosFallidosConsecutivos,
        emailVerifiedAt,
        telefonoVerifiedAt,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, tipoUsuario: $tipoUsuario)';
  }
}
