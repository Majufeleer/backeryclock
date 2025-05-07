import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginScreen.dart';
import 'ConsultaPagosScreen.dart';

class HomeScreen extends StatelessWidget {
  final String usuario;

  const HomeScreen({Key? key, required this.usuario}) : super(key: key);

  Future<Map<String, dynamic>?> obtenerDatosUsuario(String usuario) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .where('usuario', isEqualTo: usuario)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = querySnapshot.docs.first.data();
        Map<String, dynamic> horariosData = {};

        if (data.containsKey('horarios') &&
            data['horarios'] is List &&
            data['horarios'].isNotEmpty) {
          horariosData = data['horarios'][0] ?? {};
        }

        return {
          'nombre': data['nombre'] ?? 'No disponible',
          'dias': horariosData['dias'] ?? 'No disponible',
          'hora_entrada': horariosData['hora_entrada'] ?? 'No disponible',
          'hora_salida': horariosData['hora_salida'] ?? 'No disponible',
          'id': data['id'] ?? 'No disponible',
          'docId': querySnapshot.docs.first.id, // Agregamos el ID del documento
        };
      }
      return null;
    } catch (e) {
      print('Error al consultar datos: $e');
      return null;
    }
  }

  Future<void> eliminarHorario(BuildContext context, String docId) async {
    try {
      // Mostrar diálogo de confirmación
      bool confirmado = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que quieres eliminar este horario?'),
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

      if (confirmado == true) {
        // Actualizar el documento eliminando el array de horarios
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(docId)
            .update({
          'horarios': FieldValue.delete(),
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Forzar recarga de la pantalla (en un StatelessWidget necesitamos navegar de nuevo)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(usuario: usuario),
          ),
        );
      }
    } catch (e) {
      print('Error al eliminar horario: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar horario: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      body: FutureBuilder(
        future: obtenerDatosUsuario(usuario),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'No se encontraron horarios',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final datos = snapshot.data as Map<String, dynamic>;

          // Verificar si hay horarios para mostrar el botón de eliminar
          final bool tieneHorarios = datos['dias'] != 'No disponible' &&
              datos['hora_entrada'] != 'No disponible' &&
              datos['hora_salida'] != 'No disponible';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/schedule2.png',
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Consulta tu Horario',
                  style: TextStyle(
                    fontFamily: 'Tektur',
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Nombre: ${datos['nombre']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Tektur',
                  ),
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Table(
                        border: TableBorder.all(color: Colors.white),
                        children: [
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Días',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(datos['dias'],
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Hora Entrada',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(datos['hora_entrada'],
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Hora Salida',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(datos['hora_salida'],
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (tieneHorarios)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => eliminarHorario(context, datos['docId']),
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
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConsultaPagosScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Consultar Pagos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
