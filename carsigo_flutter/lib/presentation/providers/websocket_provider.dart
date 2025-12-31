import 'package:flutter/material.dart';
import '../../core/services/websocket_service.dart';
import '../../data/models/viaje.dart';

class WebSocketProvider extends ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  
  WebSocketState _state = WebSocketState.disconnected;
  Map<String, dynamic>? _ultimoViajeSolicitado;
  Map<String, dynamic>? _ultimoViajeAsignado;
  Map<String, dynamic>? _ultimoViajeEnProgreso;
  Map<String, dynamic>? _ultimoViajeCompletado;
  Map<String, dynamic>? _ultimoMensajeChat;
  Map<String, dynamic>? _ultimaUbicacionConductor;
  String? _errorMessage;

  // Getters
  WebSocketState get state => _state;
  bool get isConnected => _state == WebSocketState.connected;
  bool get isConnecting => _state == WebSocketState.connecting;
  bool get isDisconnected => _state == WebSocketState.disconnected;
  bool get hasError => _state == WebSocketState.error;
  
  Map<String, dynamic>? get ultimoViajeSolicitado => _ultimoViajeSolicitado;
  Map<String, dynamic>? get ultimoViajeAsignado => _ultimoViajeAsignado;
  Map<String, dynamic>? get ultimoViajeEnProgreso => _ultimoViajeEnProgreso;
  Map<String, dynamic>? get ultimoViajeCompletado => _ultimoViajeCompletado;
  Map<String, dynamic>? get ultimoMensajeChat => _ultimoMensajeChat;
  Map<String, dynamic>? get ultimaUbicacionConductor => _ultimaUbicacionConductor;
  String? get errorMessage => _errorMessage;

  WebSocketProvider() {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Connection state listener
    _webSocketService.connectionStateStream.listen((state) {
      _state = state;
      notifyListeners();
    });

    // Viaje solicitado listener
    _webSocketService.viajeSolicitadoStream.listen((data) {
      _ultimoViajeSolicitado = data;
      notifyListeners();
    });

    // Viaje asignado listener
    _webSocketService.viajeAsignadoStream.listen((data) {
      _ultimoViajeAsignado = data;
      notifyListeners();
    });

    // Viaje en progreso listener
    _webSocketService.viajeEnProgresoStream.listen((data) {
      _ultimoViajeEnProgreso = data;
      notifyListeners();
    });

    // Viaje completado listener
    _webSocketService.viajeCompletadoStream.listen((data) {
      _ultimoViajeCompletado = data;
      notifyListeners();
    });

    // Mensaje chat listener
    _webSocketService.mensajeChatStream.listen((data) {
      _ultimoMensajeChat = data;
      notifyListeners();
    });

    // Ubicación conductor listener
    _webSocketService.ubicacionConductorStream.listen((data) {
      _ultimaUbicacionConductor = data;
      notifyListeners();
    });
  }

  Future<void> connect(String authToken, int userId) async {
    try {
      _errorMessage = null;
      notifyListeners();
      
      await _webSocketService.initialize(authToken, userId);
    } catch (e) {
      _errorMessage = e.toString();
      _state = WebSocketState.error;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      await _webSocketService.disconnect();
      _clearData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> reconnect() async {
    try {
      _errorMessage = null;
      notifyListeners();
      
      await _webSocketService.reconnect();
    } catch (e) {
      _errorMessage = e.toString();
      _state = WebSocketState.error;
      notifyListeners();
    }
  }

  Future<void> subscribeToViaje(int viajeId) async {
    try {
      await _webSocketService.subscribeToViaje(viajeId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> unsubscribeFromViaje(int viajeId) async {
    try {
      await _webSocketService.unsubscribeFromViaje(viajeId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> subscribeToChatViaje(int viajeId) async {
    try {
      await _webSocketService.subscribeToChatViaje(viajeId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> unsubscribeFromChatViaje(int viajeId) async {
    try {
      await _webSocketService.unsubscribeFromChatViaje(viajeId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearUltimoViajeSolicitado() {
    _ultimoViajeSolicitado = null;
    notifyListeners();
  }

  void clearUltimoViajeAsignado() {
    _ultimoViajeAsignado = null;
    notifyListeners();
  }

  void clearUltimoViajeEnProgreso() {
    _ultimoViajeEnProgreso = null;
    notifyListeners();
  }

  void clearUltimoViajeCompletado() {
    _ultimoViajeCompletado = null;
    notifyListeners();
  }

  void clearUltimoMensajeChat() {
    _ultimoMensajeChat = null;
    notifyListeners();
  }

  void clearUltimaUbicacionConductor() {
    _ultimaUbicacionConductor = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearData() {
    _ultimoViajeSolicitado = null;
    _ultimoViajeAsignado = null;
    _ultimoViajeEnProgreso = null;
    _ultimoViajeCompletado = null;
    _ultimoMensajeChat = null;
    _ultimaUbicacionConductor = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}

enum WebSocketState {
  connected,
  connecting,
  disconnected,
  error,
}
