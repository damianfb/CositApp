/// Modelo de datos para Recordatorio
/// Representa recordatorios para fechas importantes (cumpleaños, eventos)
class Recordatorio {
  final int? id;
  final int? clienteId; // puede ser para un cliente específico
  final int? familiarId; // o para un familiar del cliente
  final String titulo;
  final String? descripcion;
  final DateTime fechaEvento;
  final int diasAnticipacion; // días de anticipación para el recordatorio
  final bool activo;
  final DateTime? fechaRecordatorio; // fecha calculada del recordatorio

  Recordatorio({
    this.id,
    this.clienteId,
    this.familiarId,
    required this.titulo,
    this.descripcion,
    required this.fechaEvento,
    this.diasAnticipacion = 7,
    this.activo = true,
    this.fechaRecordatorio,
  });

  /// Convierte el objeto a un Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'familiar_id': familiarId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_evento': fechaEvento.toIso8601String(),
      'dias_anticipacion': diasAnticipacion,
      'activo': activo ? 1 : 0,
      'fecha_recordatorio': fechaRecordatorio?.toIso8601String(),
    };
  }

  /// Crea un objeto Recordatorio desde un Map de SQLite
  factory Recordatorio.fromMap(Map<String, dynamic> map) {
    return Recordatorio(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int?,
      familiarId: map['familiar_id'] as int?,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String?,
      fechaEvento: DateTime.parse(map['fecha_evento'] as String),
      diasAnticipacion: map['dias_anticipacion'] as int,
      activo: (map['activo'] as int) == 1,
      fechaRecordatorio: map['fecha_recordatorio'] != null
          ? DateTime.parse(map['fecha_recordatorio'] as String)
          : null,
    );
  }

  /// Crea una copia del recordatorio con algunos campos modificados
  Recordatorio copyWith({
    int? id,
    int? clienteId,
    int? familiarId,
    String? titulo,
    String? descripcion,
    DateTime? fechaEvento,
    int? diasAnticipacion,
    bool? activo,
    DateTime? fechaRecordatorio,
  }) {
    return Recordatorio(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      familiarId: familiarId ?? this.familiarId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaEvento: fechaEvento ?? this.fechaEvento,
      diasAnticipacion: diasAnticipacion ?? this.diasAnticipacion,
      activo: activo ?? this.activo,
      fechaRecordatorio: fechaRecordatorio ?? this.fechaRecordatorio,
    );
  }

  @override
  String toString() {
    return 'Recordatorio{id: $id, titulo: $titulo, fechaEvento: $fechaEvento, diasAnticipacion: $diasAnticipacion}';
  }
}
