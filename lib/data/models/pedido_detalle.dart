/// Modelo de datos para Pedido Detalle
/// Representa el detalle de un pedido (productos específicos)
class PedidoDetalle {
  final int? id;
  final int pedidoId;
  final int productoId;
  final int? bizcochueloId; // tipo de bizcochuelo seleccionado
  final int? tematicaId; // temática de decoración seleccionada
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? tamanio; // chico, mediano, grande, kg
  final String? observaciones;

  PedidoDetalle({
    this.id,
    required this.pedidoId,
    required this.productoId,
    this.bizcochueloId,
    this.tematicaId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.tamanio,
    this.observaciones,
  });

  /// Convierte el objeto a un Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pedido_id': pedidoId,
      'producto_id': productoId,
      'bizcochuelo_id': bizcochueloId,
      'tematica_id': tematicaId,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
      'tamanio': tamanio,
      'observaciones': observaciones,
    };
  }

  /// Crea un objeto PedidoDetalle desde un Map de SQLite
  factory PedidoDetalle.fromMap(Map<String, dynamic> map) {
    return PedidoDetalle(
      id: map['id'] as int?,
      pedidoId: map['pedido_id'] as int,
      productoId: map['producto_id'] as int,
      bizcochueloId: map['bizcochuelo_id'] as int?,
      tematicaId: map['tematica_id'] as int?,
      cantidad: map['cantidad'] as int,
      precioUnitario: (map['precio_unitario'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      tamanio: map['tamanio'] as String?,
      observaciones: map['observaciones'] as String?,
    );
  }

  /// Crea una copia del detalle con algunos campos modificados
  PedidoDetalle copyWith({
    int? id,
    int? pedidoId,
    int? productoId,
    int? bizcochueloId,
    int? tematicaId,
    int? cantidad,
    double? precioUnitario,
    double? subtotal,
    String? tamanio,
    String? observaciones,
  }) {
    return PedidoDetalle(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      productoId: productoId ?? this.productoId,
      bizcochueloId: bizcochueloId ?? this.bizcochueloId,
      tematicaId: tematicaId ?? this.tematicaId,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      tamanio: tamanio ?? this.tamanio,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  String toString() {
    return 'PedidoDetalle{id: $id, pedidoId: $pedidoId, productoId: $productoId, cantidad: $cantidad, subtotal: $subtotal}';
  }
}
