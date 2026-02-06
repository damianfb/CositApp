import 'package:sqflite/sqflite.dart';
import '../models/cliente.dart';
import 'base_repository.dart';

/// Repositorio para gestión de Clientes
/// Proporciona operaciones CRUD y consultas específicas para clientes
class ClienteRepository extends BaseRepository<Cliente> {
  @override
  String get tableName => 'cliente';

  @override
  Cliente fromMap(Map<String, dynamic> map) => Cliente.fromMap(map);

  @override
  Map<String, dynamic> toMap(Cliente item) => item.toMap();

  /// Busca clientes por nombre (búsqueda parcial)
  Future<List<Cliente>> searchByName(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'nombre LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'nombre ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Obtiene solo los clientes activos
  Future<List<Cliente>> getActive() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'activo = ?',
      whereArgs: [1],
      orderBy: 'nombre ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Obtiene clientes ordenados por fecha de registro (más recientes primero)
  Future<List<Cliente>> getRecent({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'fecha_registro DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Busca un cliente por email
  Future<Cliente?> getByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  /// Busca un cliente por teléfono
  Future<Cliente?> getByPhone(String telefono) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'telefono = ?',
      whereArgs: [telefono],
    );
    
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }
}
