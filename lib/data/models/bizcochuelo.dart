/// Modelo de datos para Bizcochuelo
/// Representa los tipos de bizcochuelo disponibles (base de la torta)
class Bizcochuelo {
  final int? id;
  final String nombre;
  final String? descripcion;
  final bool activo;

  Bizcochuelo({
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

  /// Crea un objeto Bizcochuelo desde un Map de SQLite
  factory Bizcochuelo.fromMap(Map<String, dynamic> map) {
    return Bizcochuelo(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      activo: (map['activo'] as int) == 1,
    );
  }

  /// Crea una copia del bizcochuelo con algunos campos modificados
  Bizcochuelo copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    bool? activo,
  }) {
    return Bizcochuelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'Bizcochuelo{id: $id, nombre: $nombre}';
  }
}
