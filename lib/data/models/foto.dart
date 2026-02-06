/// Modelo de datos para Foto
/// Representa fotos de la galería, opcionalmente asociadas a pedidos
class Foto {
  final int? id;
  final int? pedidoId; // Opcional: null si es foto de catálogo sin pedido asociado
  final String rutaArchivo; // ruta local del archivo de imagen
  final String? descripcion;
  final String tipo; // producto_final, proceso, referencia, catalogo, otro
  final DateTime fechaCreacion;
  final bool visibleEnGaleria; // true si debe mostrarse en la galería pública
  final String? categoria; // Categoría para organizar fotos (tortas, bocaditos, decoraciones, etc.)

  Foto({
    this.id,
    this.pedidoId, // Ahora es opcional
    required this.rutaArchivo,
    this.descripcion,
    this.tipo = 'producto_final',
    required this.fechaCreacion,
    this.visibleEnGaleria = true,
    this.categoria,
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
      'visible_en_galeria': visibleEnGaleria ? 1 : 0,
      'categoria': categoria,
    };
  }

  /// Crea un objeto Foto desde un Map de SQLite
  factory Foto.fromMap(Map<String, dynamic> map) {
    return Foto(
      id: map['id'] as int?,
      pedidoId: map['pedido_id'] as int?,
      rutaArchivo: map['ruta_archivo'] as String,
      descripcion: map['descripcion'] as String?,
      tipo: map['tipo'] as String? ?? 'producto_final',
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
      visibleEnGaleria: (map['visible_en_galeria'] as int?) == 1,
      categoria: map['categoria'] as String?,
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
    bool? visibleEnGaleria,
    String? categoria,
  }) {
    return Foto(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      rutaArchivo: rutaArchivo ?? this.rutaArchivo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      visibleEnGaleria: visibleEnGaleria ?? this.visibleEnGaleria,
      categoria: categoria ?? this.categoria,
    );
  }

  @override
  String toString() {
    return 'Foto{id: $id, pedidoId: $pedidoId, tipo: $tipo, rutaArchivo: $rutaArchivo}';
  }
}
