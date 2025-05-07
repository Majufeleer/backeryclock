import 'horario.dart';

class Empleado {
  final String id; // ID único del empleado
  final String nombre; // Nombre del empleado
  final String numero; // Número de contacto
  final String tipoDeUsuario; // Tipo de usuario (Empleado, Administrador)
  final String usuario; // Nombre de usuario
  final Horario horario; // Horario del empleado
  final List<Map<String, dynamic>> pagos; // Pagos asociados al empleado

  Empleado({
    required this.id,
    required this.nombre,
    required this.numero,
    required this.tipoDeUsuario,
    required this.usuario,
    required this.horario,
    this.pagos = const [],
  });

  // Convertir el objeto Empleado a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'numero': numero,
      'tipoDeUsuario': tipoDeUsuario,
      'usuario': usuario,
      'horario': horario.toMap(),
      'pagos': pagos,
    };
  }

  // Crear un objeto Empleado a partir de un mapa de Firestore
  factory Empleado.fromMap(String id, Map<String, dynamic> map) {
    return Empleado(
      id: id, // Asignar el ID del documento de Firestore
      nombre: map['nombre'] ?? '',
      numero: map['numero'] ?? '',
      tipoDeUsuario: map['tipoDeUsuario'] ?? 'Empleado', // Valor por defecto
      usuario: map['usuario'] ?? '',
      horario: Horario.fromMap(map['horario'] ?? {}),
      pagos: List<Map<String, dynamic>>.from(map['pagos'] ?? []),
    );
  }
}
