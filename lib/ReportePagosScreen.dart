import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RegisterScheduleScreen.dart';

class ReportePagosScreen extends StatefulWidget {
  const ReportePagosScreen({Key? key}) : super(key: key);

  @override
  _ReportePagosScreenState createState() => _ReportePagosScreenState();
}

class _ReportePagosScreenState extends State<ReportePagosScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _horasController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  Future<void> registrarPago() async {
    String usuario = _usuarioController.text.trim();
    String horas = _horasController.text.trim();
    String monto = _montoController.text.trim();
    String fecha = _fechaController.text.trim();

    if (usuario.isEmpty || horas.isEmpty || monto.isEmpty || fecha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(horas)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horas debe ser un número entero')),
      );
      return;
    }

    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(monto)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto debe ser un número válido')),
      );
      return;
    }

    try {
      // Buscar el empleado por el campo "usuario" en Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('usuario', isEqualTo: usuario)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empleado no encontrado')),
        );
        return;
      }

      DocumentReference empleadoDoc = querySnapshot.docs.first.reference;

      // Obtener los pagos actuales o inicializar la lista si no existe
      Map<String, dynamic> data =
          querySnapshot.docs.first.data() as Map<String, dynamic>;
      List pagos = List.from(data['pagos'] ?? []);

      // Crear el nuevo pago
      Map<String, dynamic> nuevoPago = {
        'fecha_pago': fecha,
        'horas_trabajadas': int.parse(horas),
        'monto': double.parse(monto),
      };

      pagos.add(nuevoPago);

      // Actualizar Firestore con el nuevo pago
      await empleadoDoc.update({'pagos': pagos});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago registrado exitosamente')),
      );

      // Limpiar campos después de registrar el pago
      _usuarioController.clear();
      _horasController.clear();
      _montoController.clear();
      _fechaController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el pago: $e')),
      );
    }
  }

  void irARegisterSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScheduleScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/money1.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              "Registro de Pagos",
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
            _buildTextField(_horasController, 'Horas trabajadas'),
            _buildTextField(_montoController, 'Monto del pago'),
            _buildTextField(_fechaController, 'Fecha de pago (dd/MM/yyyy)'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: registrarPago,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Cambiado a verde
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Registrar Pago',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: irARegisterSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Cambiado a verde
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Ir a Registro de Horarios',
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
    _horasController.dispose();
    _montoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }
}
