import 'package:sqflite/sqflite.dart';
import '../../database/database_helper.dart';
import '../../models/notification_preferences.dart';

/// Repositorio para gestionar preferencias de notificaciones
/// Usa una tabla simple key-value para almacenar configuración
class NotificationPreferencesRepository {
  static final NotificationPreferencesRepository _instance = 
      NotificationPreferencesRepository._internal();
  factory NotificationPreferencesRepository() => _instance;
  NotificationPreferencesRepository._internal();

  static const String _tableName = 'notification_preferences';
  static const String _key = 'preferences';

  /// Asegura que la tabla existe
  Future<void> _ensureTableExists() async {
    final db = await DatabaseHelper.instance.database;
    
    // Verificar si la tabla existe
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$_tableName'"
    );
    
    if (tables.isEmpty) {
      // Crear tabla si no existe
      await db.execute('''
        CREATE TABLE $_tableName (
          key TEXT PRIMARY KEY,
          delivery_enabled INTEGER NOT NULL DEFAULT 1,
          delivery_days_before INTEGER NOT NULL DEFAULT 1,
          delivery_time TEXT NOT NULL DEFAULT '09:00',
          preparation_enabled INTEGER NOT NULL DEFAULT 1,
          preparation_days_before INTEGER NOT NULL DEFAULT 1,
          preparation_time TEXT NOT NULL DEFAULT '08:00',
          birthday_enabled INTEGER NOT NULL DEFAULT 1,
          birthday_days_before INTEGER NOT NULL DEFAULT 7,
          birthday_time TEXT NOT NULL DEFAULT '10:00',
          birthday_monthly_enabled INTEGER NOT NULL DEFAULT 1,
          post_sale_enabled INTEGER NOT NULL DEFAULT 1,
          post_sale_days_after INTEGER NOT NULL DEFAULT 2,
          post_sale_time TEXT NOT NULL DEFAULT '18:00'
        )
      ''');
      
      print('✅ Tabla $_tableName creada');
    }
  }

  /// Obtiene las preferencias almacenadas
  Future<NotificationPreferences> getPreferences() async {
    await _ensureTableExists();
    
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _tableName,
      where: 'key = ?',
      whereArgs: [_key],
    );

    if (results.isEmpty) {
      // Retornar preferencias por defecto
      return NotificationPreferences();
    }

    return NotificationPreferences.fromMap(results.first);
  }

  /// Guarda las preferencias
  Future<void> savePreferences(NotificationPreferences preferences) async {
    await _ensureTableExists();
    
    final db = await DatabaseHelper.instance.database;
    final map = preferences.toMap();
    map['key'] = _key;

    await db.insert(
      _tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('✅ Preferencias de notificaciones guardadas');
  }

  /// Actualiza solo un campo específico
  Future<void> updateField(String field, dynamic value) async {
    await _ensureTableExists();
    
    final db = await DatabaseHelper.instance.database;
    await db.update(
      _tableName,
      {field: value},
      where: 'key = ?',
      whereArgs: [_key],
    );
  }

  /// Restablece las preferencias a valores por defecto
  Future<void> resetToDefaults() async {
    await savePreferences(NotificationPreferences());
  }

  /// Verifica si hay preferencias guardadas
  Future<bool> hasPreferences() async {
    await _ensureTableExists();
    
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _tableName,
      where: 'key = ?',
      whereArgs: [_key],
    );

    return results.isNotEmpty;
  }
}
