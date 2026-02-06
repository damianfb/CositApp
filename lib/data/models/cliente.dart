/// Modelo de datos para Cliente
/// Representa un cliente del negocio de pastelería
class Cliente {
  final int? id;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? notas;
  final DateTime fechaRegistro;
  final bool activo;

  Cliente({
    this.id,
    required this.nombre,
    this.telefono,
    this.email,
    this.direccion,
    this.notas,
    required this.fechaRegistro,
    this.activo = true,
  });

  /// Convierte el objeto a un Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'notas': notas,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'activo': activo ? 1 : 0,
    };
  }

  /// Crea un objeto Cliente desde un Map de SQLite
  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      telefono: map['telefono'] as String?,
      email: map['email'] as String?,
      direccion: map['direccion'] as String?,
      notas: map['notas'] as String?,
      fechaRegistro: DateTime.parse(map['fecha_registro'] as String),
      activo: (map['activo'] as int) == 1,
    );
  }

  /// Crea una copia del cliente con algunos campos modificados
  Cliente copyWith({
    int? id,
    String? nombre,
    String? telefono,
    String? email,
    String? direccion,
    String? notas,
    DateTime? fechaRegistro,
    bool? activo,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      notas: notas ?? this.notas,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'Cliente{id: $id, nombre: $nombre, telefono: $telefono, email: $email}';
  }
}
