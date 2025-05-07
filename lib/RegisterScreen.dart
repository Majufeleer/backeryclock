import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // Para generar el campo id único
import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para los campos de texto
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  bool isAdmin = false; // Switch para determinar el rol del usuario
  bool showPassword = false; // Estado para mostrar/ocultar contraseña

  // Generador de id único
  final Uuid uuid = Uuid();

  // Método para registrar el usuario
  Future<void> registrarUsuario() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String nombre = nombreController.text.trim();
    final String telefono = telefonoController.text.trim();
    final String usuario = usuarioController.text.trim();
    final String id =
        isAdmin ? uuid.v4() : idController.text.trim(); // Id dinámico
    final String tipoDeUsuario = isAdmin ? 'Administrador' : 'Empleado';

    if (email.isEmpty ||
        password.isEmpty ||
        nombre.isEmpty ||
        telefono.isEmpty ||
        usuario.isEmpty ||
        (!isAdmin && id.isEmpty)) {
      // Verificar que 'Id' se complete si no es Administrador
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    try {
      // Crear usuario en Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Guardar datos adicionales en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'id': id,
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'usuario': usuario,
        'tipoDeUsuario': tipoDeUsuario,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario registrado correctamente.')),
      );

      // Navegar a la pantalla de inicio de sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50], // Fondo claro
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título
              Text(
                "Registro de Usuario",
                style: TextStyle(
                  fontFamily: 'Tektur',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[800], // Texto amarillo oscuro
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Campos de texto
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              if (!isAdmin) // Mostrar el campo Id solo si no es Administrador
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Id (Empleado)',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Switch para seleccionar rol
              SwitchListTile(
                title: Text(isAdmin ? 'Administrador' : 'Empleado'),
                value: isAdmin,
                onChanged: (value) {
                  setState(() {
                    isAdmin = value;
                    idController
                        .clear(); // Limpiar el campo Id cuando cambie el rol
                  });
                },
              ),
              const SizedBox(height: 20),
              // Botón de registro
              ElevatedButton(
                onPressed: registrarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[800],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Registrar"),
              ),
              const SizedBox(height: 20),
              // Botón para regresar
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Regresar",
                  style: TextStyle(
                    fontSize: 16,
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
