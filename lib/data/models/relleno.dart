/// Modelo de datos para Relleno
/// Representa los tipos de relleno disponibles para las tortas
class Relleno {
  final int? id;
  final String nombre;
  final String? descripcion;
  final bool activo;

  Relleno({
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

  /// Crea un objeto Relleno desde un Map de SQLite
  factory Relleno.fromMap(Map<String, dynamic> map) {
    return Relleno(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      activo: (map['activo'] as int) == 1,
    );
  }

  /// Crea una copia del relleno con algunos campos modificados
  Relleno copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    bool? activo,
  }) {
    return Relleno(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'Relleno{id: $id, nombre: $nombre}';
  }
}
