import 'package:flutter/material.dart';
import '../../data/models/notification_preferences.dart';
import '../../data/repositories/notification_preferences_repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/birthday_service.dart';

/// Pantalla de configuración de notificaciones
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _preferencesRepo = NotificationPreferencesRepository();
  final _notificationService = NotificationService();
  final _birthdayService = BirthdayService();

  NotificationPreferences? _preferences;
  bool _loading = true;
  int _pendingNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadPendingCount();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _preferencesRepo.getPreferences();
      setState(() {
        _preferences = prefs;
        _loading = false;
      });
    } catch (e) {
      print('Error al cargar preferencias: $e');
      setState(() {
        _preferences = NotificationPreferences();
        _loading = false;
      });
    }
  }

  Future<void> _loadPendingCount() async {
    try {
      final pending = await _notificationService.getPendingNotifications();
      setState(() {
        _pendingNotifications = pending.length;
      });
    } catch (e) {
      print('Error al cargar notificaciones pendientes: $e');
    }
  }

  Future<void> _savePreferences() async {
    if (_preferences == null) return;
    
    try {
      await _preferencesRepo.savePreferences(_preferences!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración guardada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error al guardar preferencias: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testNotification() async {
    try {
      await _notificationService.showInstantNotification(
        id: 99999,
        title: 'Prueba de Notificación',
        body: 'Las notificaciones están funcionando correctamente',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación de prueba enviada'),
          ),
        );
      }
    } catch (e) {
      print('Error al enviar notificación de prueba: $e');
    }
  }

  Future<void> _scheduleBirthdayNotifications() async {
    try {
      await _birthdayService.scheduleBirthdayNotifications(
        daysInAdvance: _preferences?.birthdayDaysBefore ?? 7,
      );
      
      await _loadPendingCount();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificaciones de cumpleaños programadas'),
          ),
        );
      }
    } catch (e) {
      print('Error al programar cumpleaños: $e');
    }
  }

  Future<void> _cancelAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Notificaciones'),
        content: const Text(
          '¿Estás seguro de que quieres cancelar todas las notificaciones programadas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _notificationService.cancelAllNotifications();
        await _loadPendingCount();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todas las notificaciones canceladas'),
            ),
          );
        }
      } catch (e) {
        print('Error al cancelar notificaciones: $e');
      }
    }
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: icon != null ? Icon(icon) : null,
    );
  }

  Widget _buildTimePicker({
    required String label,
    required String time,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: Text(label),
      trailing: TextButton(
        onPressed: () async {
          final parts = time.split(':');
          final initialTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );

          final newTime = await showTimePicker(
            context: context,
            initialTime: initialTime,
          );

          if (newTime != null) {
            final formattedTime =
                '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
            onChanged(formattedTime);
          }
        },
        child: Text(
          time,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNumberPicker({
    required String label,
    required int value,
    required int min,
    required int max,
    required String unit,
    required ValueChanged<int> onChanged,
  }) {
    return ListTile(
      leading: const Icon(Icons.numbers),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > min
                ? () => onChanged(value - 1)
                : null,
          ),
          Text(
            '$value $unit',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value < max
                ? () => onChanged(value + 1)
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notificaciones'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar',
            onPressed: _savePreferences,
          ),
        ],
      ),
      body: ListView(
        children: [
          // Estado de notificaciones
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active, size: 48),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estado del Sistema',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_pendingNotifications notificaciones programadas',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _testNotification,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Probar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _cancelAllNotifications,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Cancelar Todas'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Notificaciones de Entrega
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Recordatorios de Entrega',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Habilitar recordatorios',
                  subtitle: 'Notificar antes de las entregas',
                  value: _preferences?.deliveryEnabled ?? true,
                  icon: Icons.local_shipping,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences?.copyWith(
                        deliveryEnabled: value,
                      ) ?? NotificationPreferences(deliveryEnabled: value);
                    });
                  },
                ),
                if (_preferences?.deliveryEnabled ?? false) ...[
                  const Divider(height: 1),
                  _buildNumberPicker(
                    label: 'Días de anticipación',
                    value: _preferences?.deliveryDaysBefore ?? 1,
                    min: 1,
                    max: 7,
                    unit: 'días',
                    onChanged: (value) {
                      setState(() {
                        _preferences = _preferences?.copyWith(
                          deliveryDaysBefore: value,
                        );
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildTimePicker(
                    label: 'Hora de notificación',
                    time: _preferences?.deliveryTime ?? '09:00',
                    onChanged: (value) {
                      setState(() {
                        _preferences = _preferences?.copyWith(
                          deliveryTime: value,
                        );
                      });
                    },
                  ),
                ],
              ],
            ),
          ),

          // Notificaciones de Preparación
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Recordatorios de Preparación',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Habilitar recordatorios',
                  subtitle: 'Notificar cuando iniciar preparación',
                  value: _preferences?.preparationEnabled ?? true,
                  icon: Icons.kitchen,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences?.copyWith(
                        preparationEnabled: value,
                      );
                    });
                  },
                ),
                if (_preferences?.preparationEnabled ?? false) ...[
                  const Divider(height: 1),
                  _buildNumberPicker(
                    label: 'Días de anticipación',
                    value: _preferences?.preparationDaysBefore ?? 1,
                    min: 1,
                    max: 5,
                    unit: 'días',
                    onChanged: (value) {
                      setState(() {
                        _preferences = _preferences?.copyWith(
                          preparationDaysBefore: value,
                        );
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildTimePicker(
                    label: 'Hora de notificación',
                    time: _preferences?.preparationTime ?? '08:00',
                    onChanged: (value) {
                      setState(() {
                        _preferences = _preferences?.copyWith(
                          preparationTime: value,
                        );
                      });
                    },
                  ),
                ],
              ],
            ),
          ),

          // Notificaciones de Cumpleaños
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Recordatorios de Cumpleaños',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Habilitar recordatorios',
                  subtitle: 'Notificar cumpleaños próximos',
                  value: _preferences?.birthdayEnabled ?? true,
                  icon: Icons.cake,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences?.copyWith(
                        birthdayEnabled: value,
                      );
                    });
                  },
                ),
                if (_preferences?.birthdayEnabled ?? false) ...[
                  const Divider(height: 1),
                  _buildNumberPicker(
                    label: 'Días de anticipación',
                    value: _preferences?.birthdayDaysBefore ?? 7,
                    min: 1,
                    max: 30,
                    unit: 'días',
                    onChanged: (value) {
                      setState(() {
                        _preferences = _preferences?.copyWith(
                          birthdayDaysBefore: value,
                        );
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildTimePicker(
                    label: 'Hora de notificación',
                    time: _preferences?.birthdayTime ?? '10:00',
                    onChanged: (value) {
                      setState(() {
                        _preferences = _preferences?.copyWith(
                          birthdayTime: value,
                        );
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Resumen mensual',
                    subtitle: 'Notificar cumpleaños del mes',
                    value: _preferences?.birthdayMonthlyEnabled ?? true,
                    onChanged: (value) {
                      setState(() {
                        _preferences = _preferences?.copyWith(
                          birthdayMonthlyEnabled: value,
                        );
                      });
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Programar cumpleaños'),
                    subtitle: const Text('Actualizar notificaciones de cumpleaños'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _scheduleBirthdayNotifications,
                  ),
                ],
              ],
            ),
          ),

          // Notificaciones Post-Venta
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Seguimiento Post-Venta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Habilitar seguimiento',
                  subtitle: 'Recordar pedir reseñas y feedback',
                  value: _preferences?.postSaleEnabled ?? true,
                  icon: Icons.rate_review,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences?.copyWith(
                        postSaleEnabled: value,
                      );
                    });
                  },
                ),
                if (_preferences?.postSaleEnabled ?? false) ...[
                  const Divider(height: 1),
                  _buildNumberPicker(
                    label: 'Días después de entrega',
                    value: _preferences?.postSaleDaysAfter ?? 2,
                    min: 1,
                    max: 14,
                    unit: 'días',
                    onChanged: (value) {
                      setState(() {
                        _preferences = _preferences?.copyWith(
                          postSaleDaysAfter: value,
                        );
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildTimePicker(
                    label: 'Hora de notificación',
                    time: _preferences?.postSaleTime ?? '18:00',
                    onChanged: (value) {
                      setState(() {
                        _preferences = _preferences?.copyWith(
                          postSaleTime: value,
                        );
                      });
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
