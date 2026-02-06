/// Modelo de datos para Detalle Relleno
/// Representa los rellenos seleccionados para un pedido detalle
/// Un pedido detalle puede tener múltiples rellenos (capas diferentes)
class DetalleRelleno {
  final int? id;
  final int pedidoDetalleId;
  final int rellenoId;
  final int capa; // número de capa (1, 2, 3, etc.)
  final String? observaciones;

  DetalleRelleno({
    this.id,
    required this.pedidoDetalleId,
    required this.rellenoId,
    this.capa = 1,
    this.observaciones,
  });

  /// Convierte el objeto a un Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pedido_detalle_id': pedidoDetalleId,
      'relleno_id': rellenoId,
      'capa': capa,
      'observaciones': observaciones,
    };
  }

  /// Crea un objeto DetalleRelleno desde un Map de SQLite
  factory DetalleRelleno.fromMap(Map<String, dynamic> map) {
    return DetalleRelleno(
      id: map['id'] as int?,
      pedidoDetalleId: map['pedido_detalle_id'] as int,
      rellenoId: map['relleno_id'] as int,
      capa: map['capa'] as int,
      observaciones: map['observaciones'] as String?,
    );
  }

  /// Crea una copia del detalle relleno con algunos campos modificados
  DetalleRelleno copyWith({
    int? id,
    int? pedidoDetalleId,
    int? rellenoId,
    int? capa,
    String? observaciones,
  }) {
    return DetalleRelleno(
      id: id ?? this.id,
      pedidoDetalleId: pedidoDetalleId ?? this.pedidoDetalleId,
      rellenoId: rellenoId ?? this.rellenoId,
      capa: capa ?? this.capa,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  String toString() {
    return 'DetalleRelleno{id: $id, pedidoDetalleId: $pedidoDetalleId, rellenoId: $rellenoId, capa: $capa}';
  }
}
