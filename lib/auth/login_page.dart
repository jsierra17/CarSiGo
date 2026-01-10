import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);

    try {
      // 1. Iniciar el flujo de autenticación de Google
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No se pudo obtener el ID Token de Google.';
      }

      // 2. Crear una credencial de Firebase con el token de Google
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // 3. Iniciar sesión en Firebase con la credencial
      await FirebaseAuth.instance.signInWithCredential(credential);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión con Google: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
    // El AuthGate (que modificaremos a continuación) se encargará de la navegación.
  }

  @override
  Widget build(BuildContext context) {
    // El resto de la UI puede permanecer igual
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                'Bienvenido a CarSiGo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Inicia sesión para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7)),
              ),
              const Spacer(),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.white))
              else
                ElevatedButton.icon(
                  onPressed: _googleSignIn,
                  icon: Image.asset('assets/images/google_logo.png', height: 24, errorBuilder: (c, o, s) => const Icon(Icons.error)),
                  label: const Text('Continuar con Google', style: TextStyle(fontSize: 18, color: Colors.black87)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
