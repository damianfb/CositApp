import 'package:sqflite/sqflite.dart';
import '../models/familiar.dart';
import 'base_repository.dart';

/// Repositorio para gestión de Familiares
/// Proporciona operaciones CRUD y consultas específicas para familiares de clientes
class FamiliarRepository extends BaseRepository<Familiar> {
  @override
  String get tableName => 'familiar';

  @override
  Familiar fromMap(Map<String, dynamic> map) => Familiar.fromMap(map);

  @override
  Map<String, dynamic> toMap(Familiar item) => item.toMap();

  /// Obtiene todos los familiares de un cliente
  Future<List<Familiar>> getByCliente(int clienteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
      orderBy: 'nombre ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Obtiene familiares con cumpleaños próximos (dentro de N días)
  Future<List<Familiar>> getUpcomingBirthdays({int days = 30}) async {
    final db = await database;
    final now = DateTime.now();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'fecha_nacimiento IS NOT NULL',
      orderBy: 'fecha_nacimiento ASC',
    );

    final familiares = List.generate(maps.length, (i) => fromMap(maps[i]));
    
    // Filtrar por cumpleaños próximos
    return familiares.where((familiar) {
      if (familiar.fechaNacimiento == null) return false;
      
      final birthday = familiar.fechaNacimiento!;
      final nextBirthday = DateTime(
        now.year,
        birthday.month,
        birthday.day,
      );
      
      final adjustedBirthday = nextBirthday.isBefore(now)
          ? DateTime(now.year + 1, birthday.month, birthday.day)
          : nextBirthday;
      
      final difference = adjustedBirthday.difference(now).inDays;
      return difference >= 0 && difference <= days;
    }).toList();
  }

  /// Cuenta cuántos familiares tiene un cliente
  Future<int> countByCliente(int clienteId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE cliente_id = ?',
      [clienteId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
