/// Modelo de datos para Foto
/// Representa fotos asociadas a pedidos (producto final, proceso, etc.)
class Foto {
  final int? id;
  final int pedidoId;
  final String rutaArchivo; // ruta local del archivo de imagen
  final String? descripcion;
  final String tipo; // producto_final, proceso, referencia, otro
  final DateTime fechaCreacion;

  Foto({
    this.id,
    required this.pedidoId,
    required this.rutaArchivo,
    this.descripcion,
    this.tipo = 'producto_final',
    required this.fechaCreacion,
  });

  /// Convierte el objeto a un Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pedido_id': pedidoId,
      'ruta_archivo': rutaArchivo,
      'descripcion': descripcion,
      'tipo': tipo,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  /// Crea un objeto Foto desde un Map de SQLite
  factory Foto.fromMap(Map<String, dynamic> map) {
    return Foto(
      id: map['id'] as int?,
      pedidoId: map['pedido_id'] as int,
      rutaArchivo: map['ruta_archivo'] as String,
      descripcion: map['descripcion'] as String?,
      tipo: map['tipo'] as String,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  /// Crea una copia de la foto con algunos campos modificados
  Foto copyWith({
    int? id,
    int? pedidoId,
    String? rutaArchivo,
    String? descripcion,
    String? tipo,
    DateTime? fechaCreacion,
  }) {
    return Foto(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      rutaArchivo: rutaArchivo ?? this.rutaArchivo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'Foto{id: $id, pedidoId: $pedidoId, tipo: $tipo, rutaArchivo: $rutaArchivo}';
  }
}
