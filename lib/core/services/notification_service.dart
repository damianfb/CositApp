import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

/// Servicio para gestión de notificaciones locales
/// Maneja la configuración, programación y envío de notificaciones
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Argentina/Buenos_Aires'));

    // Configuración Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuración de inicialización
    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Solicita permisos de notificación (Android 13+)
  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Callback cuando se toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Implementar navegación según el payload
    debugPrint('Notificación tocada: ${response.payload}');
  }

  /// Crea un canal de notificación para Android
  Future<void> _createNotificationChannel({
    required String id,
    required String name,
    required String description,
    Importance importance = Importance.high,
  }) async {
    final androidChannel = AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: importance,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Inicializa todos los canales de notificación
  Future<void> createNotificationChannels() async {
    await _createNotificationChannel(
      id: 'delivery_reminders',
      name: 'Recordatorios de Entrega',
      description: 'Notificaciones para entregas próximas',
    );

    await _createNotificationChannel(
      id: 'birthdays',
      name: 'Cumpleaños',
      description: 'Recordatorios de cumpleaños de clientes y familiares',
    );

    await _createNotificationChannel(
      id: 'post_sale',
      name: 'Post-Venta',
      description: 'Recordatorios de seguimiento post-venta',
    );

    await _createNotificationChannel(
      id: 'preparation',
      name: 'Preparación',
      description: 'Recordatorios de preparación de pedidos',
    );
  }

  /// Programa una notificación para una fecha específica
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          channelDescription: _getChannelDescription(channelId),
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Programa notificación de recordatorio de entrega
  Future<void> scheduleDeliveryReminder({
    required int pedidoId,
    required String clienteName,
    required DateTime deliveryDate,
    required int daysBeforeToNotify,
    String? hora,
  }) async {
    final notificationDate = deliveryDate.subtract(
      Duration(days: daysBeforeToNotify),
    );

    // Si se especifica hora, usar esa hora
    DateTime finalDate = notificationDate;
    if (hora != null && hora.isNotEmpty) {
      final parts = hora.split(':');
      if (parts.length == 2) {
        finalDate = DateTime(
          notificationDate.year,
          notificationDate.month,
          notificationDate.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
    }

    await scheduleNotification(
      id: pedidoId,
      title: 'Recordatorio de Entrega',
      body: 'Pedido para $clienteName - Entrega en $daysBeforeToNotify días',
      scheduledDate: finalDate,
      channelId: 'delivery_reminders',
      payload: 'pedido_$pedidoId',
    );
  }

  /// Programa notificación de preparación
  Future<void> schedulePreparationReminder({
    required int pedidoId,
    required String clienteName,
    required DateTime preparationDate,
    String? hora,
  }) async {
    DateTime finalDate = preparationDate;
    if (hora != null && hora.isNotEmpty) {
      final parts = hora.split(':');
      if (parts.length == 2) {
        finalDate = DateTime(
          preparationDate.year,
          preparationDate.month,
          preparationDate.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
    }

    await scheduleNotification(
      id: 10000 + pedidoId,
      title: 'Recordatorio de Preparación',
      body: 'Preparar pedido para $clienteName',
      scheduledDate: finalDate,
      channelId: 'preparation',
      payload: 'pedido_$pedidoId',
    );
  }

  /// Programa notificación de cumpleaños
  Future<void> scheduleBirthdayReminder({
    required int id,
    required String name,
    required DateTime birthdayDate,
    required int daysBeforeToNotify,
  }) async {
    final notificationDate = birthdayDate.subtract(
      Duration(days: daysBeforeToNotify),
    );

    await scheduleNotification(
      id: 20000 + id,
      title: '🎂 Cumpleaños próximo',
      body: 'El cumpleaños de $name es en $daysBeforeToNotify días',
      scheduledDate: notificationDate,
      channelId: 'birthdays',
      payload: 'birthday_$id',
    );
  }

  /// Programa notificación de post-venta
  Future<void> schedulePostSaleReminder({
    required int pedidoId,
    required String clienteName,
    required DateTime deliveryDate,
    required int daysAfterDelivery,
  }) async {
    final notificationDate = deliveryDate.add(
      Duration(days: daysAfterDelivery),
    );

    await scheduleNotification(
      id: 30000 + pedidoId,
      title: 'Seguimiento Post-Venta',
      body: 'Pedir reseña a $clienteName sobre su pedido',
      scheduledDate: notificationDate,
      channelId: 'post_sale',
      payload: 'pedido_$pedidoId',
    );
  }

  /// Cancela una notificación por ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancela todas las notificaciones de un pedido
  Future<void> cancelPedidoNotifications(int pedidoId) async {
    await _notifications.cancel(pedidoId); // Delivery
    await _notifications.cancel(10000 + pedidoId); // Preparation
    await _notifications.cancel(30000 + pedidoId); // Post-sale
  }

  /// Cancela todas las notificaciones programadas
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Obtiene todas las notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Muestra una notificación inmediata
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'delivery_reminders',
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          channelDescription: _getChannelDescription(channelId),
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Obtiene el nombre del canal por ID
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'delivery_reminders':
        return 'Recordatorios de Entrega';
      case 'birthdays':
        return 'Cumpleaños';
      case 'post_sale':
        return 'Post-Venta';
      case 'preparation':
        return 'Preparación';
      default:
        return 'Notificaciones';
    }
  }

  /// Obtiene la descripción del canal por ID
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'delivery_reminders':
        return 'Notificaciones para entregas próximas';
      case 'birthdays':
        return 'Recordatorios de cumpleaños de clientes y familiares';
      case 'post_sale':
        return 'Recordatorios de seguimiento post-venta';
      case 'preparation':
        return 'Recordatorios de preparación de pedidos';
      default:
        return 'Notificaciones generales';
    }
  }
}
