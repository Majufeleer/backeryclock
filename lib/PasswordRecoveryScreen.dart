import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  // Método para verificar si el correo existe antes de enviar recuperación
  Future<void> recoverPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Primero verificamos si el correo existe
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        emailController.text.trim(),
      );

      if (methods.isEmpty) {
        setState(() {
          errorMessage = "Este correo no está registrado en nuestro sistema.";
        });
        return;
      }

      // Si existe, enviamos el correo de recuperación
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Correo de recuperación enviado correctamente.",
            style: TextStyle(
              fontFamily: 'Tektur',
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String translatedError;
      switch (e.code) {
        case 'invalid-email':
          translatedError = "El formato del correo electrónico no es válido.";
          break;
        case 'user-not-found':
          translatedError = "No existe una cuenta con este correo electrónico.";
          break;
        default:
          translatedError = "Ocurrió un error inesperado. Inténtalo de nuevo.";
      }
      setState(() {
        errorMessage = translatedError;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Ocurrió un error inesperado. Inténtalo de nuevo.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título
              Text(
                "Recuperar Contraseña",
                style: TextStyle(
                  fontFamily: 'Tektur',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[800],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Mensaje de error (si existe)
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      fontFamily: 'Tektur',
                      fontSize: 16,
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Campo de correo
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: Icon(Icons.email, color: Colors.yellow[800]),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow[800]!),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 30),

              // Botón de envío
              isLoading
                  ? CircularProgressIndicator(color: Colors.yellow[800])
                  : ElevatedButton(
                      onPressed: recoverPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Tektur',
                        ),
                      ),
                      child: const Text("Enviar Correo"),
                    ),

              const SizedBox(height: 20),

              // Botón para regresar
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Regresar",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Tektur',
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
