/// Modelo de datos para Producto
/// Representa productos finales (tortas, postres, otros productos del negocio)
class Producto {
  final int? id;
  final String nombre;
  final String? descripcion;
  final double precioBase;
  final String? categoria; // torta, postre, bocadito, etc.
  final bool activo;

  Producto({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.precioBase,
    this.categoria,
    this.activo = true,
  });

  /// Convierte el objeto a un Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_base': precioBase,
      'categoria': categoria,
      'activo': activo ? 1 : 0,
    };
  }

  /// Crea un objeto Producto desde un Map de SQLite
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      precioBase: (map['precio_base'] as num).toDouble(),
      categoria: map['categoria'] as String?,
      activo: (map['activo'] as int) == 1,
    );
  }

  /// Crea una copia del producto con algunos campos modificados
  Producto copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precioBase,
    String? categoria,
    bool? activo,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioBase: precioBase ?? this.precioBase,
      categoria: categoria ?? this.categoria,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'Producto{id: $id, nombre: $nombre, precioBase: $precioBase, categoria: $categoria}';
  }
}
