import '../models/viaje.dart';
import '../../core/services/api_service.dart';

class ViajeRepository {
  final ApiService _apiService;

  ViajeRepository(this._apiService);

  // Request a new trip
  Future<Viaje> solicitarViaje({
    required String origenDireccion,
    required double origenLatitud,
    required double origenLongitud,
    required String destinoDireccion,
    required double destinoLatitud,
    required double destinoLongitud,
    String? tipo,
    int? pasajerosSolicitados,
    String? notasEspeciales,
  }) async {
    try {
      final data = {
        'origen_direccion': origenDireccion,
        'origen_latitud': origenLatitud,
        'origen_longitud': origenLongitud,
        'destino_direccion': destinoDireccion,
        'destino_latitud': destinoLatitud,
        'destino_longitud': destinoLongitud,
        if (tipo != null) 'tipo': tipo,
        if (pasajerosSolicitados != null) 'pasajeros_solicitados': pasajerosSolicitados,
        if (notasEspeciales != null) 'notas_especiales': notasEspeciales,
      };

      final response = await _apiService.post('/viajes/solicitar', data: data);
      
      if (response.statusCode == 201 && response.data?['success'] == true) {
        final viajeData = response.data?['viaje'] as Map<String, dynamic>;
        return Viaje.fromJson(viajeData);
      } else {
        throw Exception(response.data?['message'] ?? 'Error al solicitar viaje');
      }
    } catch (e) {
      throw Exception('Error al solicitar viaje: $e');
    }
  }

  // Get trip details
  Future<Viaje> getViaje(int viajeId) async {
    try {
      final response = await _apiService.get('/viajes/$viajeId');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final viajeData = response.data?['viaje'] as Map<String, dynamic>;
        return Viaje.fromJson(viajeData);
      } else {
        throw Exception(response.data?['message'] ?? 'Error al obtener viaje');
      }
    } catch (e) {
      throw Exception('Error al obtener viaje: $e');
    }
  }

  // Get user trips (as passenger or driver)
  Future<List<Viaje>> getViajesUsuario({
    String? estado,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (estado != null) queryParams['estado'] = estado;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get('/viajes/usuario', queryParameters: queryParams);
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final viajesData = response.data?['viajes'] as List<dynamic>;
        return viajesData.map((viaje) => Viaje.fromJson(viaje as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.data?['message'] ?? 'Error al obtener viajes');
      }
    } catch (e) {
      throw Exception('Error al obtener viajes: $e');
    }
  }

  // Cancel a trip
  Future<Viaje> cancelarViaje(int viajeId, {String? motivo}) async {
    try {
      final data = <String, dynamic>{};
      if (motivo != null) data['motivo'] = motivo;

      final response = await _apiService.post('/viajes/$viajeId/cancelar', data: data);
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final viajeData = response.data?['viaje'] as Map<String, dynamic>;
        return Viaje.fromJson(viajeData);
      } else {
        throw Exception(response.data?['message'] ?? 'Error al cancelar viaje');
      }
    } catch (e) {
      throw Exception('Error al cancelar viaje: $e');
    }
  }

  // Start a trip (driver)
  Future<Viaje> iniciarViaje(int viajeId) async {
    try {
      final response = await _apiService.post('/viajes/$viajeId/iniciar');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final viajeData = response.data?['viaje'] as Map<String, dynamic>;
        return Viaje.fromJson(viajeData);
      } else {
        throw Exception(response.data?['message'] ?? 'Error al iniciar viaje');
      }
    } catch (e) {
      throw Exception('Error al iniciar viaje: $e');
    }
  }

  // Complete a trip (driver)
  Future<Viaje> completarViaje(int viajeId) async {
    try {
      final response = await _apiService.post('/viajes/$viajeId/completar');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final viajeData = response.data?['viaje'] as Map<String, dynamic>;
        return Viaje.fromJson(viajeData);
      } else {
        throw Exception(response.data?['message'] ?? 'Error al completar viaje');
      }
    } catch (e) {
      throw Exception('Error al completar viaje: $e');
    }
  }

  // Rate a trip
  Future<Map<String, dynamic>> calificarViaje({
    required int viajeId,
    required String calificacion,
    String? comentario,
  }) async {
    try {
      final data = {
        'calificacion': calificacion,
        if (comentario != null) 'comentario': comentario,
      };

      final response = await _apiService.post('/viajes/$viajeId/calificar', data: data);
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        return response.data!;
      } else {
        throw Exception(response.data?['message'] ?? 'Error al calificar viaje');
      }
    } catch (e) {
      throw Exception('Error al calificar viaje: $e');
    }
  }

  // Get available trips for drivers
  Future<List<Viaje>> getViajesDisponibles({
    double? radioKm,
    double? latitud,
    double? longitud,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (radioKm != null) queryParams['radio_km'] = radioKm;
      if (latitud != null) queryParams['latitud'] = latitud;
      if (longitud != null) queryParams['longitud'] = longitud;

      final response = await _apiService.get('/viajes/disponibles', queryParameters: queryParams);
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final viajesData = response.data?['viajes'] as List<dynamic>;
        return viajesData.map((viaje) => Viaje.fromJson(viaje as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.data?['message'] ?? 'Error al obtener viajes disponibles');
      }
    } catch (e) {
      throw Exception('Error al obtener viajes disponibles: $e');
    }
  }

  // Accept a trip (driver)
  Future<Viaje> aceptarViaje(int viajeId) async {
    try {
      final response = await _apiService.post('/viajes/$viajeId/aceptar');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final viajeData = response.data?['viaje'] as Map<String, dynamic>;
        return Viaje.fromJson(viajeData);
      } else {
        throw Exception(response.data?['message'] ?? 'Error al aceptar viaje');
      }
    } catch (e) {
      throw Exception('Error al aceptar viaje: $e');
    }
  }

  // Get trip history
  Future<List<Viaje>> getHistorialViajes({
    String? fechaInicio,
    String? fechaFin,
    String? estado,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fechaInicio != null) queryParams['fecha_inicio'] = fechaInicio;
      if (fechaFin != null) queryParams['fecha_fin'] = fechaFin;
      if (estado != null) queryParams['estado'] = estado;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiService.get('/viajes/historial', queryParameters: queryParams);
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final viajesData = response.data?['viajes'] as List<dynamic>;
        return viajesData.map((viaje) => Viaje.fromJson(viaje as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.data?['message'] ?? 'Error al obtener historial');
      }
    } catch (e) {
      throw Exception('Error al obtener historial: $e');
    }
  }
}
