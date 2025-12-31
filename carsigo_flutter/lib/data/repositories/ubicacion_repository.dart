import '../models/ubicacion.dart';
import '../../core/services/api_service.dart';

class UbicacionRepository {
  final ApiService _apiService;

  UbicacionRepository(this._apiService);

  // Save a location
  Future<Ubicacion> guardarUbicacion({
    required String nombre,
    required String direccion,
    required double latitud,
    required double longitud,
    required String tipo,
    String? descripcion,
    bool esFavorita = false,
  }) async {
    try {
      final data = {
        'nombre': nombre,
        'direccion': direccion,
        'latitud': latitud,
        'longitud': longitud,
        'tipo': tipo,
        'descripcion': descripcion,
        'es_favorita': esFavorita,
      };

      final response = await _apiService.post('/ubicaciones/guardar', data: data);
      
      if (response.statusCode == 201 && response.data?['success'] == true) {
        final ubicacionData = response.data?['ubicacion'] as Map<String, dynamic>;
        return Ubicacion.fromJson(ubicacionData);
      } else {
        throw Exception(response.data?['message'] ?? 'Error al guardar ubicación');
      }
    } catch (e) {
      throw Exception('Error al guardar ubicación: $e');
    }
  }

  // Get user locations
  Future<List<Ubicacion>> getUbicacionesUsuario() async {
    try {
      final response = await _apiService.get('/ubicaciones/usuario');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final ubicacionesData = response.data?['ubicaciones'] as List<dynamic>;
        return ubicacionesData.map((ubicacion) => Ubicacion.fromJson(ubicacion as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.data?['message'] ?? 'Error al obtener ubicaciones');
      }
    } catch (e) {
      throw Exception('Error al obtener ubicaciones: $e');
    }
  }

  // Update a location
  Future<Ubicacion> actualizarUbicacion({
    required int ubicacionId,
    String? nombre,
    String? direccion,
    double? latitud,
    double? longitud,
    String? tipo,
    String? descripcion,
    bool? esFavorita,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (direccion != null) data['direccion'] = direccion;
      if (latitud != null) data['latitud'] = latitud;
      if (longitud != null) data['longitud'] = longitud;
      if (tipo != null) data['tipo'] = tipo;
      if (descripcion != null) data['descripcion'] = descripcion;
      if (esFavorita != null) data['es_favorita'] = esFavorita;

      final response = await _apiService.put('/ubicaciones/$ubicacionId', data: data);
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final ubicacionData = response.data?['ubicacion'] as Map<String, dynamic>;
        return Ubicacion.fromJson(ubicacionData);
      } else {
        throw Exception(response.data?['message'] ?? 'Error al actualizar ubicación');
      }
    } catch (e) {
      throw Exception('Error al actualizar ubicación: $e');
    }
  }

  // Delete a location
  Future<void> eliminarUbicacion(int ubicacionId) async {
    try {
      final response = await _apiService.delete('/ubicaciones/$ubicacionId');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        return;
      } else {
        throw Exception(response.data?['message'] ?? 'Error al eliminar ubicación');
      }
    } catch (e) {
      throw Exception('Error al eliminar ubicación: $e');
    }
  }

  // Search locations by address
  Future<List<Ubicacion>> buscarUbicaciones(String query) async {
    try {
      final response = await _apiService.get('/ubicaciones/buscar', queryParameters: {
        'q': query,
      });
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final ubicacionesData = response.data?['ubicaciones'] as List<dynamic>;
        return ubicacionesData.map((ubicacion) => Ubicacion.fromJson(ubicacion as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.data?['message'] ?? 'Error al buscar ubicaciones');
      }
    } catch (e) {
      throw Exception('Error al buscar ubicaciones: $e');
    }
  }

  // Get favorite locations
  Future<List<Ubicacion>> getUbicacionesFavoritas() async {
    try {
      final response = await _apiService.get('/ubicaciones/favoritas');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final ubicacionesData = response.data?['ubicaciones'] as List<dynamic>;
        return ubicacionesData.map((ubicacion) => Ubicacion.fromJson(ubicacion as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.data?['message'] ?? 'Error al obtener ubicaciones favoritas');
      }
    } catch (e) {
      throw Exception('Error al obtener ubicaciones favoritas: $e');
    }
  }

  // Add to favorites
  Future<Ubicacion> agregarAFavoritos(int ubicacionId) async {
    try {
      final response = await _apiService.post('/ubicaciones/$ubicacionId/favorito');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final ubicacionData = response.data?['ubicacion'] as Map<String, dynamic>;
        return Ubicacion.fromJson(ubicacionData);
      } else {
        throw Exception(response.data?['message'] ?? 'Error al agregar a favoritos');
      }
    } catch (e) {
      throw Exception('Error al agregar a favoritos: $e');
    }
  }

  // Remove from favorites
  Future<Ubicacion> quitarDeFavoritos(int ubicacionId) async {
    try {
      final response = await _apiService.delete('/ubicaciones/$ubicacionId/favorito');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final ubicacionData = response.data?['ubicacion'] as Map<String, dynamic>;
        return Ubicacion.fromJson(ubicacionData);
      } else {
        throw Exception(response.data?['message'] ?? 'Error al quitar de favoritos');
      }
    } catch (e) {
      throw Exception('Error al quitar de favoritos: $e');
    }
  }

  // Get nearby places
  Future<List<Map<String, dynamic>>> getLugaresCercanos({
    required double latitud,
    required double longitud,
    double radioKm = 5.0,
    String? tipo,
  }) async {
    try {
      final queryParams = {
        'latitud': latitud,
        'longitud': longitud,
        'radio_km': radioKm,
        if (tipo != null) 'tipo': tipo,
      };

      final response = await _apiService.get('/ubicaciones/cercanos', queryParameters: queryParams);
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final lugaresData = response.data?['lugares'] as List<dynamic>;
        return lugaresData.cast<Map<String, dynamic>>();
      } else {
        throw Exception(response.data?['message'] ?? 'Error al obtener lugares cercanos');
      }
    } catch (e) {
      throw Exception('Error al obtener lugares cercanos: $e');
    }
  }

  // Get address from coordinates
  Future<String?> getDireccionDesdeCoordenadas(double latitud, double longitud) async {
    try {
      final response = await _apiService.get('/ubicaciones/direccion', queryParameters: {
        'latitud': latitud,
        'longitud': longitud,
      });
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        return response.data?['direccion'] as String?;
      } else {
        throw Exception(response.data?['message'] ?? 'Error al obtener dirección');
      }
    } catch (e) {
      throw Exception('Error al obtener dirección: $e');
    }
  }

  // Get coordinates from address
  Future<Map<String, double>?> getCoordenadasDesdeDireccion(String direccion) async {
    try {
      final response = await _apiService.get('/ubicaciones/coordenadas', queryParameters: {
        'direccion': direccion,
      });
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final data = response.data?['coordenadas'] as Map<String, dynamic>;
        return {
          'latitud': (data['latitud'] as num).toDouble(),
          'longitud': (data['longitud'] as num).toDouble(),
        };
      } else {
        throw Exception(response.data?['message'] ?? 'Error al obtener coordenadas');
      }
    } catch (e) {
      throw Exception('Error al obtener coordenadas: $e');
    }
  }
}
