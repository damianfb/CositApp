/// Modelo de datos para Tarea Postventa
/// Representa tareas de seguimiento post-entrega de pedidos
class TareaPostventa {
  final int? id;
  final int pedidoId;
  final String titulo;
  final String? descripcion;
  final DateTime fechaLimite;
  final String estado; // pendiente, en_proceso, completada, cancelada
  final DateTime? fechaCompletado;
  final String? resultado; // feedback del cliente, observaciones

  TareaPostventa({
    this.id,
    required this.pedidoId,
    required this.titulo,
    this.descripcion,
    required this.fechaLimite,
    this.estado = 'pendiente',
    this.fechaCompletado,
    this.resultado,
  });

  /// Convierte el objeto a un Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pedido_id': pedidoId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_limite': fechaLimite.toIso8601String(),
      'estado': estado,
      'fecha_completado': fechaCompletado?.toIso8601String(),
      'resultado': resultado,
    };
  }

  /// Crea un objeto TareaPostventa desde un Map de SQLite
  factory TareaPostventa.fromMap(Map<String, dynamic> map) {
    return TareaPostventa(
      id: map['id'] as int?,
      pedidoId: map['pedido_id'] as int,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String?,
      fechaLimite: DateTime.parse(map['fecha_limite'] as String),
      estado: map['estado'] as String,
      fechaCompletado: map['fecha_completado'] != null
          ? DateTime.parse(map['fecha_completado'] as String)
          : null,
      resultado: map['resultado'] as String?,
    );
  }

  /// Crea una copia de la tarea con algunos campos modificados
  TareaPostventa copyWith({
    int? id,
    int? pedidoId,
    String? titulo,
    String? descripcion,
    DateTime? fechaLimite,
    String? estado,
    DateTime? fechaCompletado,
    String? resultado,
  }) {
    return TareaPostventa(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      estado: estado ?? this.estado,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
      resultado: resultado ?? this.resultado,
    );
  }

  @override
  String toString() {
    return 'TareaPostventa{id: $id, pedidoId: $pedidoId, titulo: $titulo, estado: $estado, fechaLimite: $fechaLimite}';
  }
}
