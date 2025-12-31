import 'package:flutter/material.dart';
import '../../data/models/viaje.dart';
import '../../data/repositories/viaje_repository.dart';

enum ViajeStatus { initial, loading, success, error }

class ViajeProvider extends ChangeNotifier {
  final ViajeRepository _viajeRepository;

  ViajeProvider(this._viajeRepository);

  ViajeStatus _status = ViajeStatus.initial;
  Viaje? _viajeActual;
  List<Viaje> _viajesUsuario = [];
  List<Viaje> _viajesDisponibles = [];
  List<Viaje> _historialViajes = [];
  String? _errorMessage;

  // Getters
  ViajeStatus get status => _status;
  Viaje? get viajeActual => _viajeActual;
  List<Viaje> get viajesUsuario => _viajesUsuario;
  List<Viaje> get viajesDisponibles => _viajesDisponibles;
  List<Viaje> get historialViajes => _historialViajes;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ViajeStatus.loading;
  bool get hasViajeActivo => _viajeActual != null && 
      (_viajeActual!.isSolicitado || _viajeActual!.isAsignado || _viajeActual!.isEnProgreso);

  // Solicitar nuevo viaje
  Future<bool> solicitarViaje({
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
    _status = ViajeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final viaje = await _viajeRepository.solicitarViaje(
        origenDireccion: origenDireccion,
        origenLatitud: origenLatitud,
        origenLongitud: origenLongitud,
        destinoDireccion: destinoDireccion,
        destinoLatitud: destinoLatitud,
        destinoLongitud: destinoLongitud,
        tipo: tipo,
        pasajerosSolicitados: pasajerosSolicitados,
        notasEspeciales: notasEspeciales,
      );

      _viajeActual = viaje;
      _status = ViajeStatus.success;
      return true;
    } catch (e) {
      _status = ViajeStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Obtener detalles de un viaje
  Future<Viaje?> getViaje(int viajeId) async {
    _status = ViajeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final viaje = await _viajeRepository.getViaje(viajeId);
      _viajeActual = viaje;
      _status = ViajeStatus.success;
      return viaje;
    } catch (e) {
      _status = ViajeStatus.error;
      _errorMessage = e.toString();
      return null;
    } finally {
      notifyListeners();
    }
  }

  // Obtener viajes del usuario
  Future<void> getViajesUsuario({
    String? estado,
    int? limit,
    int? offset,
  }) async {
    _status = ViajeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final viajes = await _viajeRepository.getViajesUsuario(
        estado: estado,
        limit: limit,
        offset: offset,
      );
      _viajesUsuario = viajes;
      _status = ViajeStatus.success;
    } catch (e) {
      _status = ViajeStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Cancelar viaje
  Future<bool> cancelarViaje(int viajeId, {String? motivo}) async {
    _status = ViajeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final viaje = await _viajeRepository.cancelarViaje(viajeId, motivo: motivo);
      
      // Update current trip if it's the one being cancelled
      if (_viajeActual?.id == viajeId) {
        _viajeActual = viaje;
      }
      
      // Update user trips list
      final index = _viajesUsuario.indexWhere((v) => v.id == viajeId);
      if (index != -1) {
        _viajesUsuario[index] = viaje;
      }

      _status = ViajeStatus.success;
      return true;
    } catch (e) {
      _status = ViajeStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Iniciar viaje (conductor)
  Future<bool> iniciarViaje(int viajeId) async {
    _status = ViajeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final viaje = await _viajeRepository.iniciarViaje(viajeId);
      
      // Update current trip
      if (_viajeActual?.id == viajeId) {
        _viajeActual = viaje;
      }
      
      // Update available trips list
      _viajesDisponibles.removeWhere((v) => v.id == viajeId);

      _status = ViajeStatus.success;
      return true;
    } catch (e) {
      _status = ViajeStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Completar viaje (conductor)
  Future<bool> completarViaje(int viajeId) async {
    _status = ViajeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final viaje = await _viajeRepository.completarViaje(viajeId);
      
      // Update current trip
      if (_viajeActual?.id == viajeId) {
        _viajeActual = viaje;
      }

      _status = ViajeStatus.success;
      return true;
    } catch (e) {
      _status = ViajeStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Calificar viaje
  Future<bool> calificarViaje({
    required int viajeId,
    required String calificacion,
    String? comentario,
  }) async {
    _status = ViajeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _viajeRepository.calificarViaje(
        viajeId: viajeId,
        calificacion: calificacion,
        comentario: comentario,
      );

      if (result['success'] == true) {
        // Update current trip if it's the one being rated
        if (_viajeActual?.id == viajeId) {
          await getViaje(viajeId);
        }
        
        _status = ViajeStatus.success;
        return true;
      } else {
        _status = ViajeStatus.error;
        _errorMessage = result['message'] ?? 'Error al calificar viaje';
        return false;
      }
    } catch (e) {
      _status = ViajeStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Obtener viajes disponibles para conductores
  Future<void> getViajesDisponibles({
    double? radioKm,
    double? latitud,
    double? longitud,
  }) async {
    _status = ViajeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final viajes = await _viajeRepository.getViajesDisponibles(
        radioKm: radioKm,
        latitud: latitud,
        longitud: longitud,
      );
      _viajesDisponibles = viajes;
      _status = ViajeStatus.success;
    } catch (e) {
      _status = ViajeStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Aceptar viaje (conductor)
  Future<bool> aceptarViaje(int viajeId) async {
    _status = ViajeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final viaje = await _viajeRepository.aceptarViaje(viajeId);
      
      _viajeActual = viaje;
      _viajesDisponibles.removeWhere((v) => v.id == viajeId);

      _status = ViajeStatus.success;
      return true;
    } catch (e) {
      _status = ViajeStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Obtener historial de viajes
  Future<void> getHistorialViajes({
    String? fechaInicio,
    String? fechaFin,
    String? estado,
    int? limit,
  }) async {
    _status = ViajeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final viajes = await _viajeRepository.getHistorialViajes(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        estado: estado,
        limit: limit,
      );
      _historialViajes = viajes;
      _status = ViajeStatus.success;
    } catch (e) {
      _status = ViajeStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Limpiar viaje actual
  void clearViajeActual() {
    _viajeActual = null;
    notifyListeners();
  }

  // Actualizar estado del viaje actual
  void updateViajeStatus(String nuevoEstado) {
    if (_viajeActual != null) {
      _viajeActual = _viajeActual!.copyWith(estado: nuevoEstado);
      notifyListeners();
    }
  }

  // Obtener viajes por estado específico
  List<Viaje> getViajesPorEstado(String estado) {
    return _viajesUsuario.where((viaje) => viaje.estado == estado).toList();
  }

  // Obtener viajes activos
  List<Viaje> get viajesActivos {
    return _viajesUsuario.where((viaje) => 
        viaje.isSolicitado || viaje.isAsignado || viaje.isEnProgreso
    ).toList();
  }

  // Obtener viajes completados
  List<Viaje> get viajesCompletados {
    return _viajesUsuario.where((viaje) => viaje.isCompletado).toList();
  }

  // Obtener viajes cancelados
  List<Viaje> get viajesCancelados {
    return _viajesUsuario.where((viaje) => viaje.isCancelado).toList();
  }
}
