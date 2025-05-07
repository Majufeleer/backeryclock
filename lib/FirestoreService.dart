import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Método para guardar o actualizar el horario de un empleado
  Future<void> guardarHorario({
    required String idEmpleado,
    required String dias,
    required String horaEntrada,
    required String horaSalida,
  }) async {
    if (idEmpleado.isEmpty ||
        dias.isEmpty ||
        horaEntrada.isEmpty ||
        horaSalida.isEmpty) {
      throw Exception("Todos los campos son obligatorios");
    }

    try {
      // Verificar si el empleado existe
      final docRef = _firestore.collection('empleados').doc(idEmpleado);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        // Actualizar horario existente
        await docRef.update({
          'horario': {
            'dias': dias,
            'hora_entrada': horaEntrada,
            'hora_salida': horaSalida,
          },
        });
        print("Horario actualizado para el empleado con ID $idEmpleado");
      } else {
        // Crear un nuevo registro de empleado con horario
        await docRef.set({
          'id': idEmpleado,
          'horario': {
            'dias': dias,
            'hora_entrada': horaEntrada,
            'hora_salida': horaSalida,
          },
        });
        print("Horario guardado para el nuevo empleado con ID $idEmpleado");
      }
    } catch (e) {
      throw Exception("Error al guardar el horario: $e");
    }
  }
}
