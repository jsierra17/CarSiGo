import '../models/user.dart';
import '../../core/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

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
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        userType: userType,
        phone: phone,
        documentNumber: documentNumber,
        driverLicense: driverLicense,
        licenseExpiryDate: licenseExpiryDate,
      );
      return result;
    } catch (e) {
      throw Exception('Error en registro: $e');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authService.login(email: email, password: password);
      return result;
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      throw Exception('Error en logout: $e');
    }
  }

  // Get user profile
  Future<User> getProfile() async {
    try {
      final result = await _authService.getProfile();
      final userData = result['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  // Update user profile
  Future<User> updateProfile({
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
      final result = await _authService.updateProfile(
        name: name,
        phone: phone,
        city: city,
        department: department,
        address: address,
        bio: bio,
        gender: gender,
        birthDate: birthDate,
        profileImageUrl: profileImageUrl,
        receiveNotifications: receiveNotifications,
        receivePromotions: receivePromotions,
      );
      final userData = result['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
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
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      return result;
    } catch (e) {
      throw Exception('Error al cambiar contraseña: $e');
    }
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _authService.isAuthenticated();
  }

  // Get current user
  User? getCurrentUser() {
    final userData = _authService.getCurrentUser();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  // Get user type
  String? getUserType() {
    return _authService.getUserType();
  }

  // Get auth token
  String? getAuthToken() {
    return _authService.getAuthToken();
  }

  // Initialize auth state
  Future<void> initializeAuth() async {
    await _authService.initializeAuth();
  }
}
