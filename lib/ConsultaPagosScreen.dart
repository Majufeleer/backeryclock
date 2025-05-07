import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginScreen.dart'; // Asegúrate de importar tu pantalla de login

class ConsultaPagosScreen extends StatefulWidget {
  const ConsultaPagosScreen({Key? key}) : super(key: key);

  @override
  _ConsultaPagosScreenState createState() => _ConsultaPagosScreenState();
}

class _ConsultaPagosScreenState extends State<ConsultaPagosScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _pagos = [];
  bool _loading = true;
  String _error = '';
  String _nombreUsuario = '';
  String? _userId;

  @override
  void initState() {
    super.initState();
    _cargarPagos();
  }

  Future<void> _cargarPagos() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Usuario no autenticado';
          _loading = false;
        });
        return;
      }

      _userId = user.uid; // Guardamos el ID del usuario

      final DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(user.uid).get();

      if (!userDoc.exists) {
        setState(() {
          _error = 'No se encontraron datos del usuario';
          _loading = false;
        });
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      _nombreUsuario = userData?['nombre'] ?? 'Usuario';

      final List<dynamic>? pagosData = userData?['pagos'] as List<dynamic>?;

      if (pagosData == null || pagosData.isEmpty) {
        setState(() {
          _pagos = [];
          _loading = false;
        });
        return;
      }

      setState(() {
        _pagos = pagosData.asMap().entries.map((entry) {
          final pago = entry.value as Map<String, dynamic>;
          return {
            'fecha': pago['fecha_pago'] ?? '--/--/----',
            'horas': pago['horas_trabajadas']?.toString() ?? '0',
            'monto': pago['monto']?.toString() ?? '0',
            'telefono': pago['telefono'] ?? '',
            'index': entry.key, // Guardamos el índice para poder eliminarlo
          };
        }).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar pagos: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _eliminarPago(int index) async {
    try {
      // Mostrar diálogo de confirmación
      bool confirmado = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que quieres eliminar este pago?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmado != true) return;

      if (_userId == null) {
        throw Exception('ID de usuario no disponible');
      }

      // Obtener el documento actual
      DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(_userId).get();

      if (!userDoc.exists) {
        throw Exception('Documento de usuario no encontrado');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<dynamic> pagos = List.from(userData['pagos'] ?? []);

      // Verificar que el índice sea válido
      if (index < 0 || index >= pagos.length) {
        throw Exception('Índice de pago inválido');
      }

      // Eliminar el pago de la lista
      pagos.removeAt(index);

      // Actualizar el documento en Firestore
      await _firestore.collection('usuarios').doc(_userId).update({
        'pagos': pagos,
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Recargar los datos
      await _cargarPagos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar pago: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPaymentItem(Map<String, dynamic> pago) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.green[700],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pago del ${pago['fecha']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Horas trabajadas:', '${pago['horas']} hrs'),
                _buildInfoRow('Monto:', '\$${pago['monto']}'),
                if (pago['telefono'].toString().isNotEmpty)
                  _buildInfoRow('Teléfono:', pago['telefono']),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _eliminarPago(pago['index']),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Image.asset('assets/images/moneybag2.png', height: 100),
          const SizedBox(height: 20),
          Text(
            'Historial de Pagos',
            style: TextStyle(
              fontFamily: 'Tektur',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (_nombreUsuario.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _nombreUsuario,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _error.isNotEmpty
                    ? Center(
                        child: Text(
                          _error,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      )
                    : _pagos.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay pagos registrados',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: _pagos.length,
                            itemBuilder: (context, index) {
                              return _buildPaymentItem(_pagos[index]);
                            },
                          ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Volver',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
