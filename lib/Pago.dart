class Pago {
  final String fechaPago; // Fecha del pago
  final int horasTrabajadas; // Horas trabajadas
  final double monto; // Monto pagado
  final String
      detalles; // Detalles del pago (ej. "Salario base", "Horas extras")

  Pago({
    required this.fechaPago,
    required this.horasTrabajadas,
    required this.monto,
    required this.detalles,
  });

  // Convierte el objeto en un mapa para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'fecha_pago': fechaPago,
      'horas_trabajadas': horasTrabajadas,
      'monto': monto,
      'detalles': detalles,
    };
  }

  // Construye un objeto Pago a partir de un mapa de Firestore
  factory Pago.fromMap(Map<String, dynamic> map) {
    return Pago(
      fechaPago: map['fecha_pago'],
      horasTrabajadas: map['horas_trabajadas'],
      monto: map['monto'],
      detalles: map['detalles'],
    );
  }
}
