/// Modelo de datos para Temática
/// Representa las temáticas disponibles para decoración de tortas
class Tematica {
  final int? id;
  final String nombre;
  final String? descripcion;
  final bool activo;

  Tematica({
    this.id,
    required this.nombre,
    this.descripcion,
    this.activo = true,
  });

  /// Convierte el objeto a un Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo ? 1 : 0,
    };
  }

  /// Crea un objeto Tematica desde un Map de SQLite
  factory Tematica.fromMap(Map<String, dynamic> map) {
    return Tematica(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      activo: (map['activo'] as int) == 1,
    );
  }

  /// Crea una copia de la temática con algunos campos modificados
  Tematica copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    bool? activo,
  }) {
    return Tematica(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'Tematica{id: $id, nombre: $nombre}';
  }
}
