import 'Pago.dart';

class EmpleadoPagos {
  final String empleadoId; // Identificador único del empleado
  final String nombre; // Nombre del empleado
  List<Pago> pagos; // Lista de pagos asociados al empleado

  EmpleadoPagos({
    required this.empleadoId,
    required this.nombre,
    this.pagos = const [],
  });

  // Convierte el objeto en un mapa para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'pagos':
          pagos.map((pago) => pago.toMap()).toList(), // Convierte cada pago
    };
  }

  // Construye un objeto EmpleadoPagos a partir de un mapa de Firestore
  factory EmpleadoPagos.fromMap(String id, Map<String, dynamic> map) {
    return EmpleadoPagos(
      empleadoId: id,
      nombre: map['nombre'],
      pagos: (map['pagos'] as List<dynamic>)
          .map((pagoMap) => Pago.fromMap(pagoMap as Map<String, dynamic>))
          .toList(),
    );
  }
}
