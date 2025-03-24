import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  // Método para enviar el correo de recuperación
  Future<void> recoverPassword() async {
    setState(() {
      isLoading = true; // Mostrar indicador de carga
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Correo de recuperación enviado correctamente.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false; // Ocultar indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50], // Fondo amarillo claro
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título principal
              Text(
                "Recuperar Contraseña",
                style: TextStyle(
                  fontFamily: 'Tektur',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[800], // Texto amarillo oscuro
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // Campo de texto para ingresar el correo electrónico
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colors.yellow[800]),
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow[800]!),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Botón para enviar el correo de recuperación o mostrar el indicador de carga
              isLoading
                  ? CircularProgressIndicator(color: Colors.yellow[800])
                  : ElevatedButton(
                      onPressed: recoverPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[800]!,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text("Enviar Correo"),
                    ),
              SizedBox(height: 20),
              // Botón para regresar al inicio de sesión
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Regresa a la pantalla anterior
                },
                child: Text(
                  "Regresar",
                  style: TextStyle(
                    color: Colors.yellow[800],
                    fontWeight: FontWeight.bold,
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
