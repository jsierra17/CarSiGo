import 'package:carsigo/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  /// Registra un nuevo usuario con email y contraseña.
  Future<void> signUp({required String email, required String password}) async {
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      // Aquí se podría manejar el error, por ejemplo, mostrando un mensaje.
      print(e.message);
      rethrow;
    }
  }

  /// Inicia sesión con email y contraseña.
  Future<void> signIn({required String email, required String password}) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Escucha los cambios en el estado de autenticación.
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
}
