import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/database/database_helper.dart';

/// Servicio para backup y restore de la base de datos
/// Permite exportar e importar todos los datos de la aplicación
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Exporta toda la base de datos a un archivo JSON comprimido
  Future<File?> exportBackup() async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // Obtener todos los datos de todas las tablas
      final backup = <String, dynamic>{
        'version': 1,
        'export_date': DateTime.now().toIso8601String(),
        'app_name': 'CositApp',
      };

      // Lista de todas las tablas
      final tables = [
        'cliente',
        'familiar',
        'bizcochuelo',
        'relleno',
        'tematica',
        'producto',
        'pedido',
        'pedido_detalle',
        'detalle_relleno',
        'recordatorio',
        'tarea_postventa',
        'foto',
      ];

      // Exportar cada tabla
      for (final table in tables) {
        final data = await db.query(table);
        backup[table] = data;
      }

      // Convertir a JSON
      final jsonData = json.encode(backup);
      
      // Comprimir con gzip
      final compressed = GZipEncoder().encode(utf8.encode(jsonData));
      
      // Guardar en archivo temporal
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'cositapp_backup_$timestamp.cositbackup';
      final file = File('${directory.path}/$filename');
      
      await file.writeAsBytes(compressed!);
      
      print('✅ Backup creado: ${file.path}');
      print('📊 Tamaño: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB');
      
      return file;
    } catch (e) {
      print('❌ Error al crear backup: $e');
      return null;
    }
  }

  /// Permite al usuario seleccionar dónde guardar el backup
  Future<String?> saveBackupToExternalStorage() async {
    try {
      // Crear backup temporal
      final backupFile = await exportBackup();
      if (backupFile == null) return null;

      // Leer el contenido del archivo
      final bytes = await backupFile.readAsBytes();
      
      // Obtener directorio de descargas
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        print('❌ No se puede acceder al almacenamiento externo');
        return null;
      }

      // Crear directorio de backups si no existe
      final backupsDir = Directory('${directory.path}/Backups');
      if (!await backupsDir.exists()) {
        await backupsDir.create(recursive: true);
      }

      // Copiar archivo a ubicación pública
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'cositapp_backup_$timestamp.cositbackup';
      final destinationFile = File('${backupsDir.path}/$filename');
      await destinationFile.writeAsBytes(bytes);
      
      // Eliminar archivo temporal
      await backupFile.delete();
      
      print('✅ Backup guardado en: ${destinationFile.path}');
      return destinationFile.path;
    } catch (e) {
      print('❌ Error al guardar backup: $e');
      return null;
    }
  }

  /// Permite al usuario seleccionar un archivo de backup para restaurar
  Future<bool> importBackupFromFile() async {
    try {
      // Permitir al usuario seleccionar archivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['cositbackup', 'json'],
      );

      if (result == null || result.files.isEmpty) {
        print('⚠️ No se seleccionó ningún archivo');
        return false;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        print('❌ Ruta de archivo inválida');
        return false;
      }

      return await restoreBackup(File(filePath));
    } catch (e) {
      print('❌ Error al seleccionar archivo: $e');
      return false;
    }
  }

  /// Restaura la base de datos desde un archivo de backup
  Future<bool> restoreBackup(File backupFile) async {
    try {
      print('🔄 Iniciando restauración de backup...');
      
      // Leer archivo
      final bytes = await backupFile.readAsBytes();
      
      // Intentar descomprimir (puede ser JSON sin comprimir)
      List<int> decompressed;
      try {
        decompressed = GZipDecoder().decodeBytes(bytes);
      } catch (e) {
        // Si falla, asumir que es JSON sin comprimir
        decompressed = bytes;
      }
      
      // Decodificar JSON
      final jsonData = utf8.decode(decompressed);
      final backup = json.decode(jsonData) as Map<String, dynamic>;
      
      // Validar formato
      if (!backup.containsKey('version') || !backup.containsKey('cliente')) {
        print('❌ Formato de backup inválido');
        return false;
      }
      
      print('📦 Backup válido detectado');
      print('📅 Fecha de exportación: ${backup['export_date']}');
      
      // Obtener base de datos
      final db = await DatabaseHelper.instance.database;
      
      // Desactivar foreign keys temporalmente
      await db.execute('PRAGMA foreign_keys = OFF');
      
      // Limpiar todas las tablas
      final tables = [
        'detalle_relleno',
        'pedido_detalle',
        'tarea_postventa',
        'foto',
        'pedido',
        'recordatorio',
        'familiar',
        'cliente',
        'producto',
        'tematica',
        'relleno',
        'bizcochuelo',
      ];
      
      print('🗑️ Limpiando base de datos actual...');
      for (final table in tables) {
        await db.delete(table);
      }
      
      // Restaurar cada tabla
      print('📥 Restaurando datos...');
      int totalRecords = 0;
      
      for (final table in tables) {
        if (backup.containsKey(table)) {
          final records = backup[table] as List<dynamic>;
          print('  - Restaurando tabla $table: ${records.length} registros');
          
          for (final record in records) {
            await db.insert(table, record as Map<String, dynamic>);
            totalRecords++;
          }
        }
      }
      
      // Reactivar foreign keys
      await db.execute('PRAGMA foreign_keys = ON');
      
      print('✅ Restauración completada: $totalRecords registros');
      return true;
    } catch (e, stackTrace) {
      print('❌ Error al restaurar backup: $e');
      print(stackTrace);
      return false;
    }
  }

  /// Obtiene información de un archivo de backup sin restaurarlo
  Future<Map<String, dynamic>?> getBackupInfo(File backupFile) async {
    try {
      final bytes = await backupFile.readAsBytes();
      
      List<int> decompressed;
      try {
        decompressed = GZipDecoder().decodeBytes(bytes);
      } catch (e) {
        decompressed = bytes;
      }
      
      final jsonData = utf8.decode(decompressed);
      final backup = json.decode(jsonData) as Map<String, dynamic>;
      
      // Contar registros por tabla
      final info = <String, dynamic>{
        'version': backup['version'],
        'export_date': backup['export_date'],
        'app_name': backup['app_name'],
        'tables': <String, int>{},
        'total_records': 0,
      };
      
      final tables = [
        'cliente',
        'familiar',
        'pedido',
        'producto',
        'bizcochuelo',
        'relleno',
        'tematica',
        'foto',
      ];
      
      for (final table in tables) {
        if (backup.containsKey(table)) {
          final records = backup[table] as List<dynamic>;
          info['tables'][table] = records.length;
          info['total_records'] = (info['total_records'] as int) + records.length;
        }
      }
      
      return info;
    } catch (e) {
      print('❌ Error al leer info de backup: $e');
      return null;
    }
  }

  /// Lista todos los backups disponibles en el directorio de la app
  Future<List<FileSystemEntity>> listAvailableBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupsDir = Directory(directory.path);
      
      if (!await backupsDir.exists()) {
        return [];
      }
      
      final files = backupsDir
          .listSync()
          .where((file) => file.path.endsWith('.cositbackup'))
          .toList();
      
      // Ordenar por fecha (más reciente primero)
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      return files;
    } catch (e) {
      print('❌ Error al listar backups: $e');
      return [];
    }
  }

  /// Elimina backups antiguos, manteniendo solo los N más recientes
  Future<void> cleanOldBackups({int keepCount = 5}) async {
    try {
      final backups = await listAvailableBackups();
      
      if (backups.length <= keepCount) {
        print('ℹ️ No hay backups antiguos para eliminar');
        return;
      }
      
      final toDelete = backups.skip(keepCount);
      for (final backup in toDelete) {
        await backup.delete();
        print('🗑️ Backup antiguo eliminado: ${backup.path}');
      }
      
      print('✅ Limpieza completada: ${toDelete.length} backups eliminados');
    } catch (e) {
      print('❌ Error al limpiar backups: $e');
    }
  }

  /// Verifica la integridad de un backup
  Future<bool> verifyBackupIntegrity(File backupFile) async {
    try {
      final info = await getBackupInfo(backupFile);
      return info != null && 
             info.containsKey('version') && 
             info.containsKey('export_date') &&
             (info['total_records'] as int) > 0;
    } catch (e) {
      return false;
    }
  }
}
