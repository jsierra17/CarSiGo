import 'dart:async';
import 'dart:convert';
import 'package:pusher_client/pusher_client.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final Logger _logger = Logger();
  PusherClient? _pusher;
  String? _authToken;
  int? _userId;

  // Stream controllers
  final _viajeSolicitadoController = StreamController<Map<String, dynamic>>.broadcast();
  final _viajeAsignadoController = StreamController<Map<String, dynamic>>.broadcast();
  final _viajeEnProgresoController = StreamController<Map<String, dynamic>>.broadcast();
  final _viajeCompletadoController = StreamController<Map<String, dynamic>>.broadcast();
  final _mensajeChatController = StreamController<Map<String, dynamic>>.broadcast();
  final _ubicacionConductorController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController = StreamController<ConnectionState>.broadcast();

  // Getters
  Stream<Map<String, dynamic>> get viajeSolicitadoStream => _viajeSolicitadoController.stream;
  Stream<Map<String, dynamic>> get viajeAsignadoStream => _viajeAsignadoController.stream;
  Stream<Map<String, dynamic>> get viajeEnProgresoStream => _viajeEnProgresoController.stream;
  Stream<Map<String, dynamic>> get viajeCompletadoStream => _viajeCompletadoController.stream;
  Stream<Map<String, dynamic>> get mensajeChatStream => _mensajeChatController.stream;
  Stream<Map<String, dynamic>> get ubicacionConductorStream => _ubicacionConductorController.stream;
  Stream<ConnectionState> get connectionStateStream => _connectionStateController.stream;

  bool get isConnected => _pusher?.getConnection()?.state == 'connected';

  Future<void> initialize(String authToken, int userId) async {
    _authToken = authToken;
    _userId = userId;

    try {
      _pusher = PusherClient(
        AppConfig.pusherKey,
        PusherOptions(
          cluster: AppConfig.pusherCluster,
          auth: PusherAuth(
            '${AppConfig.apiBaseUrl}/broadcasting/auth',
            headers: {
              'Authorization': 'Bearer $authToken',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ),
      );

      // Connection state listener
      _pusher!.onConnectionStateChange((state) {
        _logger.d('Pusher connection state: $state');
        _connectionStateController.add(_parseConnectionState(state));
      });

      // Subscribe to user channels
      await _subscribeToUserChannels();

      // Subscribe to driver channels if user is driver
      await _subscribeToDriverChannels();

      _logger.i('WebSocket service initialized');
    } catch (e) {
      _logger.e('Error initializing WebSocket service: $e');
      rethrow;
    }
  }

  Future<void> _subscribeToUserChannels() async {
    if (_pusher == null || _userId == null) return;

    try {
      // User private channel
      final userChannel = _pusher!.subscribe('private-user.$_userId');
      
      userChannel.bind('viaje.asignado', (event) {
        _logger.d('Viaje asignado event received: ${event.data}');
        _viajeAsignadoController.add(Map<String, dynamic>.from(event.data));
      });

      userChannel.bind('viaje.en_progreso', (event) {
        _logger.d('Viaje en progreso event received: ${event.data}');
        _viajeEnProgresoController.add(Map<String, dynamic>.from(event.data));
      });

      userChannel.bind('viaje.completado', (event) {
        _logger.d('Viaje completado event received: ${event.data}');
        _viajeCompletadoController.add(Map<String, dynamic>.from(event.data));
      });

      userChannel.bind('chat.nuevo_mensaje', (event) {
        _logger.d('Nuevo mensaje chat event received: ${event.data}');
        _mensajeChatController.add(Map<String, dynamic>.from(event.data));
      });

      _logger.i('Subscribed to user channels');
    } catch (e) {
      _logger.e('Error subscribing to user channels: $e');
    }
  }

  Future<void> _subscribeToDriverChannels() async {
    if (_pusher == null || _userId == null) return;

    try {
      // Available drivers channel
      final driversChannel = _pusher!.subscribe('private-conductores.disponibles');
      
      driversChannel.bind('viaje.solicitado', (event) {
        _logger.d('Viaje solicitado event received: ${event.data}');
        _viajeSolicitadoController.add(Map<String, dynamic>.from(event.data));
      });

      // Driver specific channel
      final driverChannel = _pusher!.subscribe('private-conductors.$_userId');
      
      driverChannel.bind('viaje.asignado', (event) {
        _logger.d('Viaje asignado to driver event received: ${event.data}');
        _viajeAsignadoController.add(Map<String, dynamic>.from(event.data));
      });

      driverChannel.bind('viaje.en_progreso', (event) {
        _logger.d('Viaje en progreso driver event received: ${event.data}');
        _viajeEnProgresoController.add(Map<String, dynamic>.from(event.data));
      });

      driverChannel.bind('viaje.completado', (event) {
        _logger.d('Viaje completado driver event received: ${event.data}');
        _viajeCompletadoController.add(Map<String, dynamic>.from(event.data));
      });

      driverChannel.bind('chat.nuevo_mensaje', (event) {
        _logger.d('Nuevo mensaje chat driver event received: ${event.data}');
        _mensajeChatController.add(Map<String, dynamic>.from(event.data));
      });

      _logger.i('Subscribed to driver channels');
    } catch (e) {
      _logger.e('Error subscribing to driver channels: $e');
    }
  }

  Future<void> subscribeToViaje(int viajeId) async {
    if (_pusher == null) return;

    try {
      final viajeChannel = _pusher!.subscribe('private-viaje.$viajeId');
      
      viajeChannel.bind('viaje.asignado', (event) {
        _logger.d('Viaje asignado (viaje $viajeId) event received: ${event.data}');
        _viajeAsignadoController.add(Map<String, dynamic>.from(event.data));
      });

      viajeChannel.bind('viaje.en_progreso', (event) {
        _logger.d('Viaje en progreso (viaje $viajeId) event received: ${event.data}');
        _viajeEnProgresoController.add(Map<String, dynamic>.from(event.data));
      });

      viajeChannel.bind('viaje.completado', (event) {
        _logger.d('Viaje completado (viaje $viajeId) event received: ${event.data}');
        _viajeCompletadoController.add(Map<String, dynamic>.from(event.data));
      });

      viajeChannel.bind('chat.nuevo_mensaje', (event) {
        _logger.d('Nuevo mensaje chat (viaje $viajeId) event received: ${event.data}');
        _mensajeChatController.add(Map<String, dynamic>.from(event.data));
      });

      viajeChannel.bind('ubicacion.conductor', (event) {
        _logger.d('Ubicación conductor (viaje $viajeId) event received: ${event.data}');
        _ubicacionConductorController.add(Map<String, dynamic>.from(event.data));
      });

      _logger.i('Subscribed to viaje channel: private-viaje.$viajeId');
    } catch (e) {
      _logger.e('Error subscribing to viaje channel: $e');
    }
  }

  Future<void> unsubscribeFromViaje(int viajeId) async {
    if (_pusher == null) return;

    try {
      await _pusher!.unsubscribe('private-viaje.$viajeId');
      _logger.i('Unsubscribed from viaje channel: private-viaje.$viajeId');
    } catch (e) {
      _logger.e('Error unsubscribing from viaje channel: $e');
    }
  }

  Future<void> subscribeToChatViaje(int viajeId) async {
    if (_pusher == null) return;

    try {
      final chatChannel = _pusher!.subscribe('private-chat.viaje.$viajeId');
      
      chatChannel.bind('chat.nuevo_mensaje', (event) {
        _logger.d('Nuevo mensaje chat (chat viaje $viajeId) event received: ${event.data}');
        _mensajeChatController.add(Map<String, dynamic>.from(event.data));
      });

      _logger.i('Subscribed to chat channel: private-chat.viaje.$viajeId');
    } catch (e) {
      _logger.e('Error subscribing to chat channel: $e');
    }
  }

  Future<void> unsubscribeFromChatViaje(int viajeId) async {
    if (_pusher == null) return;

    try {
      await _pusher!.unsubscribe('private-chat.viaje.$viajeId');
      _logger.i('Unsubscribed from chat channel: private-chat.viaje.$viajeId');
    } catch (e) {
      _logger.e('Error unsubscribing from chat channel: $e');
    }
  }

  ConnectionState _parseConnectionState(String state) {
    switch (state) {
      case 'connected':
        return ConnectionState.connected;
      case 'connecting':
        return ConnectionState.connecting;
      case 'disconnected':
        return ConnectionState.disconnected;
      case 'failed':
        return ConnectionState.failed;
      default:
        return ConnectionState.unknown;
    }
  }

  Future<void> disconnect() async {
    try {
      await _pusher?.disconnect();
      _pusher = null;
      _authToken = null;
      _userId = null;
      
      // Close all stream controllers
      await _viajeSolicitadoController.close();
      await _viajeAsignadoController.close();
      await _viajeEnProgresoController.close();
      await _viajeCompletadoController.close();
      await _mensajeChatController.close();
      await _ubicacionConductorController.close();
      await _connectionStateController.close();
      
      _logger.i('WebSocket service disconnected');
    } catch (e) {
      _logger.e('Error disconnecting WebSocket service: $e');
    }
  }

  Future<void> reconnect() async {
    if (_authToken != null && _userId != null) {
      await disconnect();
      await initialize(_authToken!, _userId!);
    }
  }

  void dispose() {
    disconnect();
  }
}

enum ConnectionState {
  connected,
  connecting,
  disconnected,
  failed,
  unknown,
}
