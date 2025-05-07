class Horario {
  final String dias;
  final String horaEntrada;
  final String horaSalida;

  Horario({
    required this.dias,
    required this.horaEntrada,
    required this.horaSalida,
  });

  // Convertir Horario a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'dias': dias,
      'hora_entrada': horaEntrada,
      'hora_salida': horaSalida,
    };
  }

  // Crear un Horario a partir de un mapa
  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      dias: map['dias'] ?? '',
      horaEntrada: map['hora_entrada'] ?? '',
      horaSalida: map['hora_salida'] ?? '',
    );
  }
}
