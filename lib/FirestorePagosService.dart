import 'Pago.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePagosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Agregar un nuevo pago para una empleada
  Future<void> agregarPago(String empleadoId, Pago nuevoPago) async {
    final docRef = _firestore.collection('empleados').doc(empleadoId);

    try {
      final doc = await docRef.get();
      if (doc.exists) {
        final empleadoData = doc.data();
        final pagos = (empleadoData!['pagos'] as List<dynamic>?)
                ?.map((pago) => Pago.fromMap(pago))
                .toList() ??
            [];
        pagos.add(nuevoPago);

        await docRef
            .update({'pagos': pagos.map((pago) => pago.toMap()).toList()});
        print('Pago añadido correctamente.');
      }
    } catch (e) {
      print('Error al agregar el pago: $e');
    }
  }

  /// Obtener pagos de una empleada
  Future<List<Pago>> obtenerPagos(String empleadoId) async {
    try {
      final doc =
          await _firestore.collection('empleados').doc(empleadoId).get();
      if (doc.exists) {
        final data = doc.data();
        final pagos = (data?['pagos'] as List<dynamic>?)
                ?.map((pago) => Pago.fromMap(pago))
                .toList() ??
            [];
        return pagos;
      }
      return [];
    } catch (e) {
      print('Error al obtener pagos: $e');
      return [];
    }
  }

  /// Eliminar un pago específico
  Future<void> eliminarPago(String empleadoId, String fechaPago) async {
    final docRef = _firestore.collection('empleados').doc(empleadoId);

    try {
      final doc = await docRef.get();
      if (doc.exists) {
        final empleadoData = doc.data();
        final pagos = (empleadoData!['pagos'] as List<dynamic>?)
                ?.map((pago) => Pago.fromMap(pago))
                .toList() ??
            [];
        pagos.removeWhere((pago) => pago.fechaPago == fechaPago);

        await docRef
            .update({'pagos': pagos.map((pago) => pago.toMap()).toList()});
        print('Pago eliminado correctamente.');
      }
    } catch (e) {
      print('Error al eliminar el pago: $e');
    }
  }
}
