/// Modelo de datos para Familiar
/// Representa un familiar de un cliente (para cumpleaños, eventos especiales)
class Familiar {
  final int? id;
  final int clienteId;
  final String nombre;
  final DateTime? fechaNacimiento;
  final String? parentesco; // hijo, esposo/a, padre, madre, etc.
  final String? notas;

  Familiar({
    this.id,
    required this.clienteId,
    required this.nombre,
    this.fechaNacimiento,
    this.parentesco,
    this.notas,
  });

  /// Convierte el objeto a un Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'nombre': nombre,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'parentesco': parentesco,
      'notas': notas,
    };
  }

  /// Crea un objeto Familiar desde un Map de SQLite
  factory Familiar.fromMap(Map<String, dynamic> map) {
    return Familiar(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int,
      nombre: map['nombre'] as String,
      fechaNacimiento: map['fecha_nacimiento'] != null
          ? DateTime.parse(map['fecha_nacimiento'] as String)
          : null,
      parentesco: map['parentesco'] as String?,
      notas: map['notas'] as String?,
    );
  }

  /// Crea una copia del familiar con algunos campos modificados
  Familiar copyWith({
    int? id,
    int? clienteId,
    String? nombre,
    DateTime? fechaNacimiento,
    String? parentesco,
    String? notas,
  }) {
    return Familiar(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      nombre: nombre ?? this.nombre,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      parentesco: parentesco ?? this.parentesco,
      notas: notas ?? this.notas,
    );
  }

  @override
  String toString() {
    return 'Familiar{id: $id, nombre: $nombre, parentesco: $parentesco, clienteId: $clienteId}';
  }
}
