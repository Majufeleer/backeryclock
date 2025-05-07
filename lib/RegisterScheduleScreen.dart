import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginScreen.dart';

class RegisterScheduleScreen extends StatefulWidget {
  @override
  _RegisterScheduleScreenState createState() => _RegisterScheduleScreenState();
}

class _RegisterScheduleScreenState extends State<RegisterScheduleScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _diasController = TextEditingController();
  final TextEditingController _horaEntradaController = TextEditingController();
  final TextEditingController _horaSalidaController = TextEditingController();

  Future<void> _registrarHorario() async {
    final String usuario = _usuarioController.text.trim();
    final String dias = _diasController.text.trim();
    final String horaEntrada = _horaEntradaController.text.trim();
    final String horaSalida = _horaSalidaController.text.trim();

    if (usuario.isEmpty ||
        dias.isEmpty ||
        horaEntrada.isEmpty ||
        horaSalida.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('usuario', isEqualTo: usuario)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empleado no encontrado')),
        );
        return;
      }

      DocumentReference usuarioDoc = querySnapshot.docs.first.reference;

      Map<String, dynamic>? data =
          querySnapshot.docs.first.data() as Map<String, dynamic>?;
      List horarios = data != null && data['horarios'] != null
          ? List.from(data['horarios'])
          : [];

      var nuevoHorario = {
        'dias': dias,
        'hora_entrada': horaEntrada,
        'hora_salida': horaSalida,
      };

      horarios.add(nuevoHorario);

      await usuarioDoc.update({
        'horarios': horarios,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horario registrado con éxito')),
      );

      _usuarioController.clear();
      _diasController.clear();
      _horaEntradaController.clear();
      _horaSalidaController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar horario: $e')),
      );
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF87CEEB), // Azul cielo
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/schedule.png', // Ruta correcta sin cambios
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              "Registrar Horarios",
              style: TextStyle(
                fontFamily: 'Tektur',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildTextField(_usuarioController, 'Usuario del Empleado'),
            _buildTextField(_diasController, 'Días'),
            _buildTextField(_horaEntradaController, 'Hora de Entrada'),
            _buildTextField(_horaSalidaController, 'Hora de Salida'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registrarHorario,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // Botón amarillo
                foregroundColor: Colors.white, // Texto en blanco
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Registrar Horario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cerrarSesion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Botón rojo para cerrar sesión
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _diasController.dispose();
    _horaEntradaController.dispose();
    _horaSalidaController.dispose();
    super.dispose();
  }
}
