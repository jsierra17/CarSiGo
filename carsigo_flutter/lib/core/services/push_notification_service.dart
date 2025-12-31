import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final Logger _logger = Logger();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  StreamController<RemoteMessage>? _messageController;
  StreamController<RemoteMessage>? _backgroundMessageController;

  // Getters
  String? get fcmToken => _fcmToken;
  Stream<RemoteMessage> get onMessage => _messageController?.stream ?? const Stream.empty();
  Stream<RemoteMessage> get onBackgroundMessage => _backgroundMessageController?.stream ?? const Stream.empty();

  Future<void> initialize() async {
    try {
      // Request permission
      await _requestPermission();
      
      // Get FCM token
      await _getFCMToken();
      
      // Initialize message handlers
      _initializeMessageHandlers();
      
      // Save token locally
      await _saveTokenLocally();
      
      _logger.i('Push notification service initialized');
    } catch (e) {
      _logger.e('Error initializing push notification service: $e');
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        _logger.i('User granted provisional permission');
      } else {
        _logger.w('User declined or has not accepted permission');
      }
    } else if (Platform.isAndroid) {
      final settings = await _firebaseMessaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('Android permission granted');
      }
    }
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      _logger.i('FCM Token: $_fcmToken');
      
      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh((token) {
        _fcmToken = token;
        _logger.i('FCM Token refreshed: $token');
        _saveTokenLocally();
      });
    } catch (e) {
      _logger.e('Error getting FCM token: $e');
    }
  }

  void _initializeMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    // Handle message when app opens from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Handle initial message (when app is opened from terminated state)
    _firebaseMessaging.getInitialMessage().then(_handleInitialMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _logger.d('Received foreground message: ${message.messageId}');
    
    // Add to stream for UI to handle
    _messageController?.add(message);
    
    // Show in-app notification
    _showInAppNotification(message);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    Logger().d('Received background message: ${message.messageId}');
    
    // Handle background notification
    // This is static as required by Firebase
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _logger.d('App opened from notification: ${message.messageId}');
    
    // Navigate to appropriate screen based on notification data
    _handleNotificationNavigation(message.data);
  }

  void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      _logger.d('App opened from initial notification: ${message.messageId}');
      _handleNotificationNavigation(message.data);
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic>? data) {
    if (data == null) return;
    
    final type = data['type'];
    final viajeId = data['viaje_id'];
    
    switch (type) {
      case 'viaje_solicitado':
        // Navigate to available trips for drivers
        _navigateToAvailableTrips();
        break;
      case 'viaje_asignado':
      case 'viaje_en_progreso':
      case 'viaje_completado':
        if (viajeId != null) {
          _navigateToTripDetails(int.parse(viajeId.toString()));
        }
        break;
      case 'chat_mensaje':
        if (viajeId != null) {
          _navigateToChat(int.parse(viajeId.toString()));
        }
        break;
      default:
        // Navigate to home
        _navigateToHome();
    }
  }

  void _showInAppNotification(RemoteMessage message) {
    // This would show a custom in-app notification
    // Implementation depends on your UI framework
    _logger.d('Showing in-app notification: ${message.notification?.title}');
  }

  void _navigateToHome() {
    // Navigate to home screen
    // Implementation depends on your navigation system
  }

  void _navigateToAvailableTrips() {
    // Navigate to available trips screen
    // Implementation depends on your navigation system
  }

  void _navigateToTripDetails(int viajeId) {
    // Navigate to trip details screen
    // Implementation depends on your navigation system
  }

  void _navigateToChat(int viajeId) {
    // Navigate to chat screen
    // Implementation depends on your navigation system
  }

  Future<void> _saveTokenLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.fcmTokenKey, _fcmToken ?? '');
      _logger.d('FCM token saved locally');
    } catch (e) {
      _logger.e('Error saving FCM token locally: $e');
    }
  }

  Future<String?> getSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConfig.fcmTokenKey);
    } catch (e) {
      _logger.e('Error getting saved FCM token: $e');
      return null;
    }
  }

  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConfig.fcmTokenKey);
      _fcmToken = null;
      _logger.d('FCM token cleared');
    } catch (e) {
      _logger.e('Error clearing FCM token: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.i('Subscribed to topic: $topic');
    } catch (e) {
      _logger.e('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.e('Error unsubscribing from topic $topic: $e');
    }
  }

  Future<void> subscribeToUserNotifications(int userId) async {
    await subscribeToTopic('user_$userId');
  }

  Future<void> unsubscribeFromUserNotifications(int userId) async {
    await unsubscribeFromTopic('user_$userId');
  }

  Future<void> subscribeToDriverNotifications() async {
    await subscribeToTopic('drivers');
  }

  Future<void> unsubscribeFromDriverNotifications() async {
    await unsubscribeFromTopic('drivers');
  }

  Future<void> subscribeToTripNotifications(int viajeId) async {
    await subscribeToTopic('viaje_$viajeId');
  }

  Future<void> unsubscribeFromTripNotifications(int viajeId) async {
    await unsubscribeFromTopic('viaje_$viajeId');
  }

  void dispose() {
    _messageController?.close();
    _backgroundMessageController?.close();
  }
}
