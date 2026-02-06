import 'package:sqflite/sqflite.dart';
import '../models/producto.dart';
import '../models/bizcochuelo.dart';
import '../models/relleno.dart';
import '../models/tematica.dart';
import 'base_repository.dart';

/// Repositorio para gestión de Productos
/// Proporciona operaciones CRUD y consultas específicas para productos
class ProductoRepository extends BaseRepository<Producto> {
  @override
  String get tableName => 'producto';

  @override
  Producto fromMap(Map<String, dynamic> map) => Producto.fromMap(map);

  @override
  Map<String, dynamic> toMap(Producto item) => item.toMap();

  /// Obtiene productos por categoría
  Future<List<Producto>> getByCategory(String categoria) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'categoria = ? AND activo = ?',
      whereArgs: [categoria, 1],
      orderBy: 'nombre ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Obtiene solo los productos activos
  Future<List<Producto>> getActive() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'activo = ?',
      whereArgs: [1],
      orderBy: 'nombre ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Busca productos por nombre
  Future<List<Producto>> searchByName(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'nombre LIKE ? AND activo = ?',
      whereArgs: ['%$query%', 1],
      orderBy: 'nombre ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
}

/// Repositorio para gestión de Bizcochuelos
class BizcochueloRepository extends BaseRepository<Bizcochuelo> {
  @override
  String get tableName => 'bizcochuelo';

  @override
  Bizcochuelo fromMap(Map<String, dynamic> map) => Bizcochuelo.fromMap(map);

  @override
  Map<String, dynamic> toMap(Bizcochuelo item) => item.toMap();

  /// Obtiene solo los bizcochuelos activos
  Future<List<Bizcochuelo>> getActive() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'activo = ?',
      whereArgs: [1],
      orderBy: 'nombre ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
}

/// Repositorio para gestión de Rellenos
class RellenoRepository extends BaseRepository<Relleno> {
  @override
  String get tableName => 'relleno';

  @override
  Relleno fromMap(Map<String, dynamic> map) => Relleno.fromMap(map);

  @override
  Map<String, dynamic> toMap(Relleno item) => item.toMap();

  /// Obtiene solo los rellenos activos
  Future<List<Relleno>> getActive() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'activo = ?',
      whereArgs: [1],
      orderBy: 'nombre ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
}

/// Repositorio para gestión de Temáticas
class TematicaRepository extends BaseRepository<Tematica> {
  @override
  String get tableName => 'tematica';

  @override
  Tematica fromMap(Map<String, dynamic> map) => Tematica.fromMap(map);

  @override
  Map<String, dynamic> toMap(Tematica item) => item.toMap();

  /// Obtiene solo las temáticas activas
  Future<List<Tematica>> getActive() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'activo = ?',
      whereArgs: [1],
      orderBy: 'nombre ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
}
