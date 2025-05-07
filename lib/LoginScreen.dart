import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ReportePagosScreen.dart';
import 'RegisterScreen.dart';
import 'PasswordRecoveryScreen.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Resetear errores
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    if (email.isEmpty) {
      setState(() => _emailError = 'Por favor, ingresa tu correo electrónico');
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Por favor, ingresa tu contraseña');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuario no encontrado',
        );
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuario no registrado en el sistema',
        );
      }

      Map<String, dynamic> userData = querySnapshot.docs.first.data();
      String tipoUsuario = (userData['tipoDeUsuario'] ?? 'Empleado').toString();
      String nombreUsuario = userData['usuario'] ?? '';

      if (tipoUsuario.toLowerCase() == 'administrador') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReportePagosScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(usuario: nombreUsuario),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Usuario no encontrado';
          setState(() => _emailError = errorMessage);
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta';
          setState(() => _passwordError = errorMessage);
          break;
        case 'invalid-email':
          errorMessage = 'Correo electrónico inválido';
          setState(() => _emailError = errorMessage);
          break;
        case 'user-disabled':
          errorMessage = 'Cuenta deshabilitada. Contacta al administrador.';
          setState(() => _generalError = errorMessage);
          break;
        case 'too-many-requests':
          errorMessage = 'Demasiados intentos. Cuenta temporalmente bloqueada.';
          setState(() => _generalError = errorMessage);
          break;
        case 'operation-not-allowed':
          errorMessage = 'Operación no permitida. Contacta al administrador.';
          setState(() => _generalError = errorMessage);
          break;
        case 'network-request-failed':
          errorMessage = 'Error de conexión. Verifica tu internet.';
          setState(() => _generalError = errorMessage);
          break;
        case 'invalid-credential':
        case 'credential-malformed-or-expired':
          errorMessage =
              'Credenciales incorrectas o expiradas. Por favor, verifica tus datos.';
          setState(() => _generalError = errorMessage);
          break;
        default:
          errorMessage = _translateFirebaseError(e.code, e.message ?? '');
          setState(() => _generalError = errorMessage);
      }
    } catch (e) {
      setState(() => _generalError =
          'Ocurrió un error inesperado. Por favor, intenta nuevamente.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _translateFirebaseError(String code, String originalMessage) {
    switch (code) {
      case 'invalid-credential':
        return 'Credenciales de autenticación inválidas. Verifica tus datos.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este correo pero con diferente método de autenticación.';
      case 'requires-recent-login':
        return 'Esta operación requiere que inicies sesión nuevamente.';
      case 'provider-already-linked':
        return 'Este método de autenticación ya está vinculado a tu cuenta.';
      case 'no-such-provider':
        return 'Método de autenticación no disponible.';
      case 'invalid-verification-code':
        return 'Código de verificación inválido.';
      case 'invalid-verification-id':
        return 'ID de verificación inválido.';
      case 'session-cookie-expired':
        return 'La sesión ha expirado. Por favor, inicia sesión nuevamente.';
      case 'invalid-user-token':
        return 'Token de usuario inválido. Inicia sesión nuevamente.';
      case 'user-token-expired':
        return 'Token de usuario expirado. Inicia sesión nuevamente.';
      default:
        return 'Error al iniciar sesión: ${originalMessage.isNotEmpty ? originalMessage : 'Por favor, verifica tus datos e intenta nuevamente.'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Backery Clock',
                style: TextStyle(
                  fontFamily: 'Tektur',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[700],
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.pink[300]!,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              if (_generalError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      _generalError!,
                      style: TextStyle(
                        color: Colors.red[800],
                        fontFamily: 'Tektur',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 15),
              _buildTextField(_emailController, 'Correo Electrónico',
                  Icons.email, false, _emailError),
              const SizedBox(height: 15),
              _buildTextField(_passwordController, 'Contraseña', Icons.lock,
                  true, _passwordError),
              const SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator(color: Colors.pink[700])
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Tektur',
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        shadowColor: Colors.pink[300],
                      ),
                      child: const Text('INICIAR SESIÓN'),
                    ),
              const SizedBox(height: 20),
              _buildTextButton('Registrarse', RegisterScreen()),
              const SizedBox(height: 10),
              _buildTextButton(
                  'Recuperar contraseña', PasswordRecoveryScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isPassword, String? errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.pink[100]!,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !_showPassword,
            style: const TextStyle(fontFamily: 'Tektur'),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.pink[700],
                fontFamily: 'Tektur',
              ),
              prefixIcon: Icon(icon, color: Colors.pink[700]),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.pink[700],
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(15),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 10),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red[700],
                fontFamily: 'Tektur',
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextButton(String text, Widget screen) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.pink[700],
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'Tektur',
          decoration: TextDecoration.underline,
          shadows: [
            Shadow(
              color: Colors.pink[100]!,
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
