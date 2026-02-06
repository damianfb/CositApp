import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/foto.dart';
import 'base_repository.dart';

/// Repositorio para gestionar fotos
/// Maneja CRUD y operaciones específicas de fotos
class FotoRepository extends BaseRepository<Foto> {
  @override
  String get tableName => 'foto';

  @override
  Foto fromMap(Map<String, dynamic> map) {
    return Foto.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(Foto item) {
    return item.toMap();
  }

  /// Obtiene todas las fotos de un pedido específico
  Future<List<Foto>> getByPedido(int pedidoId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      tableName,
      where: 'pedido_id = ?',
      whereArgs: [pedidoId],
      orderBy: 'fecha_creacion DESC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  /// Obtiene fotos por tipo
  Future<List<Foto>> getByTipo(String tipo) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      tableName,
      where: 'tipo = ?',
      whereArgs: [tipo],
      orderBy: 'fecha_creacion DESC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  /// Obtiene fotos por categoría
  Future<List<Foto>> getByCategoria(String categoria) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      tableName,
      where: 'categoria = ?',
      whereArgs: [categoria],
      orderBy: 'fecha_creacion DESC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  /// Obtiene todas las fotos visibles en la galería
  Future<List<Foto>> getVisiblesEnGaleria() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      tableName,
      where: 'visible_en_galeria = ?',
      whereArgs: [1],
      orderBy: 'fecha_creacion DESC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  /// Obtiene fotos de la galería filtradas por categoría
  Future<List<Foto>> getVisiblesByCategoria(String? categoria) async {
    final db = await DatabaseHelper.instance.database;
    
    if (categoria == null || categoria.isEmpty) {
      return getVisiblesEnGaleria();
    }
    
    final maps = await db.query(
      tableName,
      where: 'visible_en_galeria = ? AND categoria = ?',
      whereArgs: [1, categoria],
      orderBy: 'fecha_creacion DESC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  /// Obtiene fotos sin pedido asociado (fotos de catálogo)
  Future<List<Foto>> getFotosCatalogo() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      tableName,
      where: 'pedido_id IS NULL',
      orderBy: 'fecha_creacion DESC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  /// Obtiene todas las categorías únicas existentes
  Future<List<String>> getCategorias() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT categoria FROM $tableName WHERE categoria IS NOT NULL ORDER BY categoria'
    );
    return result
        .map((row) => row['categoria'] as String)
        .toList();
  }

  /// Cuenta fotos por categoría
  Future<Map<String, int>> countByCategoria() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT categoria, COUNT(*) as count 
      FROM $tableName 
      WHERE categoria IS NOT NULL AND visible_en_galeria = 1
      GROUP BY categoria
    ''');
    
    final Map<String, int> counts = {};
    for (final row in result) {
      final categoria = row['categoria'] as String;
      final count = row['count'] as int;
      counts[categoria] = count;
    }
    return counts;
  }

  /// Elimina todas las fotos de un pedido
  Future<int> deleteByPedido(int pedidoId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      tableName,
      where: 'pedido_id = ?',
      whereArgs: [pedidoId],
    );
  }

  /// Actualiza la visibilidad de una foto en la galería
  Future<int> updateVisibilidad(int id, bool visible) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      tableName,
      {'visible_en_galeria': visible ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Busca fotos por descripción (búsqueda simple)
  Future<List<Foto>> searchByDescripcion(String query) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      tableName,
      where: 'descripcion LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'fecha_creacion DESC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  /// Obtiene el conteo total de fotos
  Future<int> getTotalCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Obtiene el conteo de fotos visibles en galería
  Future<int> getVisiblesCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE visible_en_galeria = 1'
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
