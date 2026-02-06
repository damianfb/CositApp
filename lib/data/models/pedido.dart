/// Modelo de datos para Pedido
/// Representa un pedido realizado por un cliente
class Pedido {
  final int? id;
  final int clienteId;
  final DateTime fechaPedido;
  final DateTime fechaEntrega;
  final String estado; // pendiente, confirmado, en_proceso, completado, cancelado
  final double precioTotal;
  final double? senia; // seña o adelanto
  final String? observaciones;
  final DateTime? fechaCompletado;

  Pedido({
    this.id,
    required this.clienteId,
    required this.fechaPedido,
    required this.fechaEntrega,
    this.estado = 'pendiente',
    required this.precioTotal,
    this.senia,
    this.observaciones,
    this.fechaCompletado,
  });

  /// Convierte el objeto a un Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'fecha_pedido': fechaPedido.toIso8601String(),
      'fecha_entrega': fechaEntrega.toIso8601String(),
      'estado': estado,
      'precio_total': precioTotal,
      'senia': senia,
      'observaciones': observaciones,
      'fecha_completado': fechaCompletado?.toIso8601String(),
    };
  }

  /// Crea un objeto Pedido desde un Map de SQLite
  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int,
      fechaPedido: DateTime.parse(map['fecha_pedido'] as String),
      fechaEntrega: DateTime.parse(map['fecha_entrega'] as String),
      estado: map['estado'] as String,
      precioTotal: (map['precio_total'] as num).toDouble(),
      senia: map['senia'] != null ? (map['senia'] as num).toDouble() : null,
      observaciones: map['observaciones'] as String?,
      fechaCompletado: map['fecha_completado'] != null
          ? DateTime.parse(map['fecha_completado'] as String)
          : null,
    );
  }

  /// Crea una copia del pedido con algunos campos modificados
  Pedido copyWith({
    int? id,
    int? clienteId,
    DateTime? fechaPedido,
    DateTime? fechaEntrega,
    String? estado,
    double? precioTotal,
    double? senia,
    String? observaciones,
    DateTime? fechaCompletado,
  }) {
    return Pedido(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      fechaPedido: fechaPedido ?? this.fechaPedido,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      estado: estado ?? this.estado,
      precioTotal: precioTotal ?? this.precioTotal,
      senia: senia ?? this.senia,
      observaciones: observaciones ?? this.observaciones,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
    );
  }

  @override
  String toString() {
    return 'Pedido{id: $id, clienteId: $clienteId, fechaEntrega: $fechaEntrega, estado: $estado, precioTotal: $precioTotal}';
  }
}
