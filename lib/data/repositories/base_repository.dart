import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

/// Repositorio base con operaciones CRUD genéricas
/// Proporciona métodos comunes para todos los repositorios
abstract class BaseRepository<T> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  /// Nombre de la tabla en la base de datos
  String get tableName;

  /// Obtiene la instancia de la base de datos
  Future<Database> get database async => await _dbHelper.database;

  /// Convierte un Map a un objeto del tipo T
  T fromMap(Map<String, dynamic> map);

  /// Convierte un objeto del tipo T a un Map
  Map<String, dynamic> toMap(T item);

  /// Inserta un nuevo registro
  Future<int> insert(T item) async {
    final db = await database;
    return await db.insert(
      tableName,
      toMap(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene todos los registros
  Future<List<T>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Obtiene un registro por ID
  Future<T?> getById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  /// Actualiza un registro existente
  Future<int> update(T item, int id) async {
    final db = await database;
    return await db.update(
      tableName,
      toMap(item),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Elimina un registro por ID
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Elimina todos los registros de la tabla
  Future<int> deleteAll() async {
    final db = await database;
    return await db.delete(tableName);
  }

  /// Cuenta el número total de registros
  Future<int> count() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
