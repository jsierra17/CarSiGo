import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository) {
    _initializeAuth();
  }

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Initialize auth state
  Future<void> _initializeAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authRepository.initializeAuth();
      
      if (_authRepository.isAuthenticated()) {
        final currentUser = _authRepository.getCurrentUser();
        if (currentUser != null) {
          _user = currentUser;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Register new user
  Future<bool> register({
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
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.register(
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

      if (result['success'] == true) {
        _status = AuthStatus.unauthenticated;
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = result['message'] ?? 'Error en el registro';
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(email: email, password: password);

      if (result['success'] == true) {
        final userData = result['user'] as Map<String, dynamic>;
        _user = User.fromJson(userData);
        _status = AuthStatus.authenticated;
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = result['message'] ?? 'Error en el login';
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authRepository.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Get user profile
  Future<void> getProfile() async {
    if (!isAuthenticated) return;

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.getProfile();
      _user = user;
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
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
    if (!isAuthenticated) return false;

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authRepository.updateProfile(
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

      _user = updatedUser;
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    if (!isAuthenticated) return false;

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      if (result['success'] == true) {
        _status = AuthStatus.authenticated;
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = result['message'] ?? 'Error al cambiar contraseña';
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (isAuthenticated) {
      await getProfile();
    }
  }

  // Check if user is of specific type
  bool isUserType(String type) {
    return _user?.tipoUsuario == type;
  }

  // Get user type
  String? get userType => _user?.tipoUsuario;

  // Check if account is active
  bool get isAccountActive => _user?.estadoCuenta == 'activa';

  // Check if account is suspended
  bool get isAccountSuspended => _user?.estadoCuenta == 'suspendida';

  // Check if account is in verification
  bool get isAccountVerification => _user?.estadoCuenta == 'verificacion';
}
