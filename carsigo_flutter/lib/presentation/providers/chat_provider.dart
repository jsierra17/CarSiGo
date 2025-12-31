import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../providers/websocket_provider.dart';

class ChatMessage {
  final int id;
  final int viajeId;
  final int remitenteId;
  final int destinatarioId;
  final String contenido;
  final String tipo;
  final Map<String, dynamic>? metadata;
  final DateTime? leidoEn;
  final DateTime createdAt;
  final Map<String, dynamic> remitente;
  final bool esMio;
  final bool leido;

  ChatMessage({
    required this.id,
    required this.viajeId,
    required this.remitenteId,
    required this.destinatarioId,
    required this.contenido,
    required this.tipo,
    this.metadata,
    this.leidoEn,
    required this.createdAt,
    required this.remitente,
    required this.esMio,
    required this.leido,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      viajeId: json['viaje_id'] as int,
      remitenteId: json['remitente_id'] as int,
      destinatarioId: json['destinatario_id'] as int,
      contenido: json['contenido'] as String,
      tipo: json['tipo'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      leidoEn: json['leido_en'] != null ? DateTime.parse(json['leido_en']) : null,
      createdAt: DateTime.parse(json['created_at']),
      remitente: json['remitente'] as Map<String, dynamic>,
      esMio: json['es mio'] as bool,
      leido: json['leido'] as bool,
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
  final WebSocketProvider _webSocketProvider;

  ChatProvider(this._apiService, this._webSocketProvider) {
    _initializeWebSocketListener();
  }

  // State
  bool _isLoading = false;
  String? _errorMessage;
  List<ChatMessage> _mensajes = [];
  Map<int, List<ChatMessage>> _mensajesPorViaje = {};
  Map<int, int> _noLeidosCount = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ChatMessage> get mensajes => _mensajes;
  Map<int, List<ChatMessage>> get mensajesPorViaje => _mensajesPorViaje;
  Map<int, int> get noLeidosCount => _noLeidosCount;

  void _initializeWebSocketListener() {
    _webSocketService.mensajeChatStream.listen((data) {
      _handleNuevoMensaje(data);
    });
  }

  void _handleNuevoMensaje(Map<String, dynamic> data) {
    final mensaje = ChatMessage.fromJson(data['mensaje']);
    
    // Add to general messages list
    _mensajes.insert(0, mensaje);
    
    // Add to viaje-specific messages
    if (!_mensajesPorViaje.containsKey(mensaje.viajeId)) {
      _mensajesPorViaje[mensaje.viajeId] = [];
    }
    _mensajesPorViaje[mensaje.viajeId]!.insert(0, mensaje);
    
    // Update unread count
    if (!mensaje.esMio && !mensaje.leido) {
      _noLeidosCount[mensaje.viajeId] = (_noLeidosCount[mensaje.viajeId] ?? 0) + 1;
    }
    
    notifyListeners();
  }

  Future<void> obtenerMensajesViaje(int viajeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/chat/viajes/$viajeId/mensajes');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final mensajesData = response.data?['mensajes'] as List<dynamic>;
        final mensajes = mensajesData.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>)).toList();
        
        _mensajesPorViaje[viajeId] = mensajes;
        
        // Update unread count
        int noLeidos = mensajes.where((m) => !m.esMio && !m.leido).length;
        _noLeidosCount[viajeId] = noLeidos;
        
        notifyListeners();
      } else {
        _errorMessage = response.data?['message'] ?? 'Error al obtener mensajes';
      }
    } catch (e) {
      _errorMessage = 'Error al obtener mensajes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enviarMensaje({
    required int viajeId,
    required String contenido,
    String tipo = 'texto',
    Map<String, dynamic>? metadata,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = {
        'contenido': contenido,
        'tipo': tipo,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _apiService.post('/chat/viajes/$viajeId/mensajes', data: data);
      
      if (response.statusCode == 201 && response.data?['success'] == true) {
        final mensajeData = response.data?['mensaje'] as Map<String, dynamic>;
        final mensaje = ChatMessage.fromJson(mensajeData);
        
        // Add to messages
        if (!_mensajesPorViaje.containsKey(viajeId)) {
          _mensajesPorViaje[viajeId] = [];
        }
        _mensajesPorViaje[viajeId]!.insert(0, mensaje);
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data?['message'] ?? 'Error al enviar mensaje';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al enviar mensaje: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> marcarComoLeidos(int viajeId) async {
    try {
      final response = await _apiService.post('/chat/viajes/$viajeId/leidos');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        // Mark all messages as read
        if (_mensajesPorViaje.containsKey(viajeId)) {
          for (var mensaje in _mensajesPorViaje[viajeId]!) {
            if (!mensaje.esMio && !mensaje.leido) {
              mensaje.leidoEn = DateTime.now();
            }
          }
        }
        
        _noLeidosCount[viajeId] = 0;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data?['message'] ?? 'Error al marcar mensajes como leídos';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al marcar mensajes como leídos: $e';
      return false;
    }
  }

  Future<bool> eliminarMensaje(int mensajeId) async {
    try {
      final response = await _apiService.delete('/chat/mensajes/$mensajeId');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        // Remove message from lists
        _mensajes.removeWhere((m) => m.id == mensajeId);
        
        for (var viajeId in _mensajesPorViaje.keys) {
          _mensajesPorViaje[viajeId]!.removeWhere((m) => m.id == mensajeId);
        }
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data?['message'] ?? 'Error al eliminar mensaje';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al eliminar mensaje: $e';
      return false;
    }
  }

  List<ChatMessage> getMensajesViaje(int viajeId) {
    return _mensajesPorViaje[viajeId] ?? [];
  }

  int getNoLeidosCountViaje(int viajeId) {
    return _noLeidosCount[viajeId] ?? 0;
  }

  int getTotalNoLeidosCount() {
    return _noLeidosCount.values.fold(0, (sum, count) => sum + count);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearMensajesViaje(int viajeId) {
    _mensajesPorViaje.remove(viajeId);
    _noLeidosCount.remove(viajeId);
    notifyListeners();
  }

  void clearAllMensajes() {
    _mensajes.clear();
    _mensajesPorViaje.clear();
    _noLeidosCount.clear();
    notifyListeners();
  }

  String getPreviewMensaje(ChatMessage mensaje) {
    switch (mensaje.tipo) {
      case 'texto':
        return mensaje.contenido.length > 50 
            ? '${mensaje.contenido.substring(0, 50)}...' 
            : mensaje.contenido;
      case 'imagen':
        return '📷 Imagen';
      case 'ubicacion':
        return '📍 Ubicación compartida';
      case 'sistema':
        return mensaje.contenido;
      default:
        return 'Nuevo mensaje';
    }
  }

  bool esMensajeReciente(ChatMessage mensaje) {
    final now = DateTime.now();
    final difference = now.difference(mensaje.createdAt);
    return difference.inMinutes < 5;
  }

  String getFormatoTiempo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
