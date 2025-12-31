import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/ubicacion.dart';
import '../../data/repositories/ubicacion_repository.dart';
import '../../core/services/location_service.dart';

enum UbicacionStatus { initial, loading, success, error }

class UbicacionProvider extends ChangeNotifier {
  final UbicacionRepository _ubicacionRepository;
  final LocationService _locationService;

  UbicacionProvider(this._ubicacionRepository, this._locationService);

  UbicacionStatus _status = UbicacionStatus.initial;
  Position? _currentPosition;
  String? _currentAddress;
  List<Ubicacion> _ubicacionesUsuario = [];
  List<Ubicacion> _ubicacionesFavoritas = [];
  List<Map<String, dynamic>> _lugaresCercanos = [];
  String? _errorMessage;

  // Getters
  UbicacionStatus get status => _status;
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  List<Ubicacion> get ubicacionesUsuario => _ubicacionesUsuario;
  List<Ubicacion> get ubicacionesFavoritas => _ubicacionesFavoritas;
  List<Map<String, dynamic>> get lugaresCercanos => _lugaresCercanos;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == UbicacionStatus.loading;
  bool get hasCurrentLocation => _currentPosition != null;

  // Obtener ubicación actual
  Future<bool> getCurrentLocation() async {
    _status = UbicacionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if location service is enabled
      final isEnabled = await _locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        _status = UbicacionStatus.error;
        _errorMessage = 'El servicio de ubicación está desactivado';
        return false;
      }

      // Check permissions
      final hasPermission = await _locationService.hasLocationPermission();
      if (!hasPermission) {
        _status = UbicacionStatus.error;
        _errorMessage = 'Se requieren permisos de ubicación';
        return false;
      }

      // Get current position
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _currentPosition = position;
        
        // Get address from coordinates
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        _currentAddress = address;
        
        _status = UbicacionStatus.success;
        return true;
      } else {
        _status = UbicacionStatus.error;
        _errorMessage = 'No se pudo obtener la ubicación actual';
        return false;
      }
    } catch (e) {
      _status = UbicacionStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Guardar ubicación
  Future<bool> guardarUbicacion({
    required String nombre,
    required String direccion,
    required double latitud,
    required double longitud,
    required String tipo,
    String? descripcion,
    bool esFavorita = false,
  }) async {
    _status = UbicacionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final ubicacion = await _ubicacionRepository.guardarUbicacion(
        nombre: nombre,
        direccion: direccion,
        latitud: latitud,
        longitud: longitud,
        tipo: tipo,
        descripcion: descripcion,
        esFavorita: esFavorita,
      );

      _ubicacionesUsuario.add(ubicacion);
      if (esFavorita) {
        _ubicacionesFavoritas.add(ubicacion);
      }

      _status = UbicacionStatus.success;
      return true;
    } catch (e) {
      _status = UbicacionStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Obtener ubicaciones del usuario
  Future<void> getUbicacionesUsuario() async {
    _status = UbicacionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final ubicaciones = await _ubicacionRepository.getUbicacionesUsuario();
      _ubicacionesUsuario = ubicaciones;
      _ubicacionesFavoritas = ubicaciones.where((u) => u.esFavorita).toList();
      _status = UbicacionStatus.success;
    } catch (e) {
      _status = UbicacionStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Actualizar ubicación
  Future<bool> actualizarUbicacion({
    required int ubicacionId,
    String? nombre,
    String? direccion,
    double? latitud,
    double? longitud,
    String? tipo,
    String? descripcion,
    bool? esFavorita,
  }) async {
    _status = UbicacionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final ubicacion = await _ubicacionRepository.actualizarUbicacion(
        ubicacionId: ubicacionId,
        nombre: nombre,
        direccion: direccion,
        latitud: latitud,
        longitud: longitud,
        tipo: tipo,
        descripcion: descripcion,
        esFavorita: esFavorita,
      );

      // Update in user locations list
      final index = _ubicacionesUsuario.indexWhere((u) => u.id == ubicacionId);
      if (index != -1) {
        _ubicacionesUsuario[index] = ubicacion;
      }

      // Update favorites list
      _ubicacionesFavoritas = _ubicacionesUsuario.where((u) => u.esFavorita).toList();

      _status = UbicacionStatus.success;
      return true;
    } catch (e) {
      _status = UbicacionStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Eliminar ubicación
  Future<bool> eliminarUbicacion(int ubicacionId) async {
    _status = UbicacionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ubicacionRepository.eliminarUbicacion(ubicacionId);

      _ubicacionesUsuario.removeWhere((u) => u.id == ubicacionId);
      _ubicacionesFavoritas.removeWhere((u) => u.id == ubicacionId);

      _status = UbicacionStatus.success;
      return true;
    } catch (e) {
      _status = UbicacionStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Buscar ubicaciones
  Future<List<Ubicacion>> buscarUbicaciones(String query) async {
    _status = UbicacionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final ubicaciones = await _ubicacionRepository.buscarUbicaciones(query);
      _status = UbicacionStatus.success;
      return ubicaciones;
    } catch (e) {
      _status = UbicacionStatus.error;
      _errorMessage = e.toString();
      return [];
    } finally {
      notifyListeners();
    }
  }

  // Obtener ubicaciones favoritas
  Future<void> getUbicacionesFavoritas() async {
    _status = UbicacionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final favoritas = await _ubicacionRepository.getUbicacionesFavoritas();
      _ubicacionesFavoritas = favoritas;
      _status = UbicacionStatus.success;
    } catch (e) {
      _status = UbicacionStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Agregar a favoritos
  Future<bool> agregarAFavoritos(int ubicacionId) async {
    _status = UbicacionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final ubicacion = await _ubicacionRepository.agregarAFavoritos(ubicacionId);

      // Update in user locations list
      final index = _ubicacionesUsuario.indexWhere((u) => u.id == ubicacionId);
      if (index != -1) {
        _ubicacionesUsuario[index] = ubicacion;
      }

      // Add to favorites list
      if (!_ubicacionesFavoritas.any((u) => u.id == ubicacionId)) {
        _ubicacionesFavoritas.add(ubicacion);
      }

      _status = UbicacionStatus.success;
      return true;
    } catch (e) {
      _status = UbicacionStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Quitar de favoritos
  Future<bool> quitarDeFavoritos(int ubicacionId) async {
    _status = UbicacionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final ubicacion = await _ubicacionRepository.quitarDeFavoritos(ubicacionId);

      // Update in user locations list
      final index = _ubicacionesUsuario.indexWhere((u) => u.id == ubicacionId);
      if (index != -1) {
        _ubicacionesUsuario[index] = ubicacion;
      }

      // Remove from favorites list
      _ubicacionesFavoritas.removeWhere((u) => u.id == ubicacionId);

      _status = UbicacionStatus.success;
      return true;
    } catch (e) {
      _status = UbicacionStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Obtener lugares cercanos
  Future<void> getLugaresCercanos({
    double? radioKm,
    String? tipo,
  }) async {
    if (_currentPosition == null) {
      _status = UbicacionStatus.error;
      _errorMessage = 'Se requiere ubicación actual';
      notifyListeners();
      return;
    }

    _status = UbicacionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final lugares = await _ubicacionRepository.getLugaresCercanos(
        latitud: _currentPosition!.latitude,
        longitud: _currentPosition!.longitude,
        radioKm: radioKm ?? 5.0,
        tipo: tipo,
      );
      _lugaresCercanos = lugares;
      _status = UbicacionStatus.success;
    } catch (e) {
      _status = UbicacionStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Obtener dirección desde coordenadas
  Future<String?> getDireccionDesdeCoordenadas(double latitud, double longitud) async {
    try {
      return await _ubicacionRepository.getDireccionDesdeCoordenadas(latitud, longitud);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  // Obtener coordenadas desde dirección
  Future<Map<String, double>?> getCoordenadasDesdeDireccion(String direccion) async {
    try {
      return await _ubicacionRepository.getCoordenadasDesdeDireccion(direccion);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Limpiar ubicación actual
  void clearCurrentLocation() {
    _currentPosition = null;
    _currentAddress = null;
    notifyListeners();
  }

  // Obtener ubicaciones por tipo
  List<Ubicacion> getUbicacionesPorTipo(String tipo) {
    return _ubicacionesUsuario.where((u) => u.tipo.toLowerCase() == tipo.toLowerCase()).toList();
  }

  // Obtener ubicaciones de casa
  List<Ubicacion> get ubicacionesCasa => getUbicacionesPorTipo('casa');

  // Obtener ubicaciones de trabajo
  List<Ubicacion> get ubicacionesTrabajo => getUbicacionesPorTipo('trabajo');

  // Obtener otras ubicaciones
  List<Ubicacion> get otrasUbicaciones => getUbicacionesPorTipo('otro');

  // Calcular distancia a una ubicación
  double calcularDistanciaAUbicacion(double latitud, double longitud) {
    if (_currentPosition == null) return 0.0;
    
    return _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitud,
      longitud,
    );
  }

  // Formatear distancia
  String formatearDistancia(double metros) {
    if (metros < 1000) {
      return '${metros.toStringAsFixed(0)} m';
    } else {
      return '${(metros / 1000).toStringAsFixed(1)} km';
    }
  }
}
