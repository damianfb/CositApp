import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/backup_service.dart';

/// Pantalla para gestión de backups y restore
class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final _backupService = BackupService();
  
  List<FileSystemEntity> _backups = [];
  bool _loading = false;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() {
      _loading = true;
    });

    try {
      final backups = await _backupService.listAvailableBackups();
      setState(() {
        _backups = backups;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error al listar backups: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _createBackup() async {
    setState(() {
      _creating = true;
    });

    try {
      final backupFile = await _backupService.exportBackup();
      
      if (backupFile != null) {
        await _loadBackups();
        
        if (mounted) {
          // Preguntar si quiere compartir el backup
          final share = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Backup Creado'),
              content: const Text(
                'El backup se ha creado exitosamente.\n\n'
                '¿Deseas compartir el archivo de backup?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Compartir'),
                ),
              ],
            ),
          );

          if (share == true) {
            await Share.shareXFiles(
              [XFile(backupFile.path)],
              text: 'Backup de CositApp',
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al crear backup'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al crear backup: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _creating = false;
      });
    }
  }

  Future<void> _restoreFromFile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Advertencia'),
        content: const Text(
          'Restaurar un backup reemplazará TODOS los datos actuales.\n\n'
          'Esta acción no se puede deshacer.\n\n'
          '¿Estás seguro de que quieres continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _loading = true;
    });

    try {
      final success = await _backupService.importBackupFromFile();
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Backup restaurado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Recargar app después de 2 segundos
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          // Mostrar diálogo de reinicio recomendado
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Restauración Completa'),
              content: const Text(
                'Los datos se han restaurado exitosamente.\n\n'
                'Se recomienda reiniciar la aplicación.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al restaurar backup'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al restaurar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _restoreFromBackup(File backupFile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar Restauración'),
        content: const Text(
          'Esto reemplazará TODOS los datos actuales con este backup.\n\n'
          '¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _loading = true;
    });

    try {
      final success = await _backupService.restoreBackup(backupFile);
      
      if (success) {
        await _loadBackups();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Backup restaurado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al restaurar backup'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al restaurar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _shareBackup(File backupFile) async {
    try {
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        text: 'Backup de CositApp',
      );
    } catch (e) {
      debugPrint('Error al compartir: $e');
    }
  }

  Future<void> _deleteBackup(File backupFile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Backup'),
        content: const Text('¿Estás seguro de eliminar este backup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await backupFile.delete();
        await _loadBackups();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup eliminado')),
          );
        }
      } catch (e) {
        debugPrint('Error al eliminar: $e');
      }
    }
  }

  Future<void> _showBackupInfo(File backupFile) async {
    final info = await _backupService.getBackupInfo(backupFile);
    
    if (info == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo leer la información del backup'),
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${info['export_date']}'),
            Text('Versión: ${info['version']}'),
            const SizedBox(height: 16),
            const Text(
              'Registros:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(info['tables'] as Map<String, int>).entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text('${entry.key}: ${entry.value}'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${info['total_records']} registros',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCard(FileSystemEntity entity) {
    final file = File(entity.path);
    final stat = file.statSync();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'es');
    final sizeKB = (stat.size / 1024).toStringAsFixed(2);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.backup, color: Colors.white),
        ),
        title: Text(
          'Backup ${dateFormat.format(stat.modified)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$sizeKB KB'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('Ver información'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore),
                  SizedBox(width: 8),
                  Text('Restaurar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Compartir'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'info':
                _showBackupInfo(file);
                break;
              case 'restore':
                _restoreFromBackup(file);
                break;
              case 'share':
                _shareBackup(file);
                break;
              case 'delete':
                _deleteBackup(file);
                break;
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup y Restore'),
      ),
      body: Column(
        children: [
          // Botones de acción
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _creating ? null : _createBackup,
                    icon: _creating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.backup),
                    label: Text(_creating ? 'Creando...' : 'Crear Backup'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _restoreFromFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Restaurar desde Archivo'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de backups
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Backups Disponibles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadBackups,
                ),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _backups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.backup_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay backups disponibles',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea tu primer backup',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _backups.length,
                        itemBuilder: (context, index) {
                          return _buildBackupCard(_backups[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
