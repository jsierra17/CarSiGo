import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  AuthService(this._apiService, this._prefs);

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String userType,
    required String phone,
    required String documentNumber,
    String? driverLicense,
    String? licenseExpiryDate,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'tipo_usuario': userType,
        'telefono': phone,
        'numero_documento': documentNumber,
        if (driverLicense != null) 'numero_licencia': driverLicense,
        if (licenseExpiryDate != null) 'fecha_vencimiento_licencia': licenseExpiryDate,
      };

      final response = await _apiService.post('/auth/registro', data: data);
      
      if (response.statusCode == 201 && response.data?['success'] == true) {
        return response.data!;
      } else {
        throw Exception(response.data?['message'] ?? 'Error en el registro');
      }
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };

      final response = await _apiService.post('/auth/login', data: data);
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final token = response.data?['token'];
        final user = response.data?['user'];
        
        if (token != null && user != null) {
          // Save token and user data
          await _saveAuthToken(token);
          await _saveUserData(user);
          
          // Set token in API service
          _apiService.setAuthToken(token);
          
          return response.data!;
        } else {
          throw Exception('Respuesta de login inválida');
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Error en el login');
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Even if logout fails, clear local data
    } finally {
      await _clearAuthData();
      _apiService.setAuthToken(null);
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get('/auth/perfil');
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final user = response.data?['user'];
        if (user != null) {
          await _saveUserData(user);
        }
        return response.data!;
      } else {
        throw Exception(response.data?['message'] ?? 'Error al obtener perfil');
      }
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? city,
    String? department,
    String? address,
    String? bio,
    String? gender,
    String? birthDate,
    String? profileImageUrl,
    bool? receiveNotifications,
    bool? receivePromotions,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (name != null) data['name'] = name;
      if (phone != null) data['telefono'] = phone;
      if (city != null) data['ciudad'] = city;
      if (department != null) data['departamento'] = department;
      if (address != null) data['direccion'] = address;
      if (bio != null) data['bio'] = bio;
      if (gender != null) data['genero'] = gender;
      if (birthDate != null) data['fecha_nacimiento'] = birthDate;
      if (profileImageUrl != null) data['foto_perfil_url'] = profileImageUrl;
      if (receiveNotifications != null) data['recibir_notificaciones'] = receiveNotifications;
      if (receivePromotions != null) data['recibir_promociones'] = receivePromotions;

      final response = await _apiService.put('/auth/perfil', data: data);
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final user = response.data?['user'];
        if (user != null) {
          await _saveUserData(user);
        }
        return response.data!;
      } else {
        throw Exception(response.data?['message'] ?? 'Error al actualizar perfil');
      }
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final data = {
        'password_actual': currentPassword,
        'password_nueva': newPassword,
        'password_nueva_confirmation': newPasswordConfirmation,
      };

      final response = await _apiService.post('/auth/cambiar-password', data: data);
      
      if (response.statusCode == 200 && response.data?['success'] == true) {
        return response.data!;
      } else {
        throw Exception(response.data?['message'] ?? 'Error al cambiar contraseña');
      }
    } catch (e) {
      throw Exception('Error al cambiar contraseña: $e');
    }
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    final token = _prefs.getString(AppConfig.tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Get current user
  Map<String, dynamic>? getCurrentUser() {
    final userJson = _prefs.getString(AppConfig.userProfileKey);
    if (userJson != null) {
      return Map<String, dynamic>.from(json.decode(userJson));
    }
    return null;
  }

  // Get user type
  String? getUserType() {
    return _prefs.getString(AppConfig.userTypeKey);
  }

  // Get auth token
  String? getAuthToken() {
    return _prefs.getString(AppConfig.tokenKey);
  }

  // Initialize auth state
  Future<void> initializeAuth() async {
    final token = getAuthToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  // Save auth token
  Future<void> _saveAuthToken(String token) async {
    await _prefs.setString(AppConfig.tokenKey, token);
  }

  // Save user data
  Future<void> _saveUserData(Map<String, dynamic> user) async {
    await _prefs.setString(AppConfig.userIdKey, user['id'].toString());
    await _prefs.setString(AppConfig.userTypeKey, user['tipo_usuario']);
    await _prefs.setString(AppConfig.userProfileKey, json.encode(user));
  }

  // Clear auth data
  Future<void> _clearAuthData() async {
    await _prefs.remove(AppConfig.tokenKey);
    await _prefs.remove(AppConfig.userIdKey);
    await _prefs.remove(AppConfig.userTypeKey);
    await _prefs.remove(AppConfig.userProfileKey);
  }
}
