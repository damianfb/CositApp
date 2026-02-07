import 'package:flutter/foundation.dart';
import '../../data/repositories/cliente_repository.dart';
import '../../data/repositories/familiar_repository.dart';
import '../../data/models/cliente.dart';
import '../../data/models/familiar.dart';
import 'notification_service.dart';

/// Modelo para cumpleaños del mes
class BirthdayInfo {
  final int id;
  final String nombre;
  final DateTime fechaNacimiento;
  final String tipo; // 'cliente' o 'familiar'
  final int? clienteId; // Para familiares
  final String? clienteNombre; // Para familiares
  final String? telefono;

  BirthdayInfo({
    required this.id,
    required this.nombre,
    required this.fechaNacimiento,
    required this.tipo,
    this.clienteId,
    this.clienteNombre,
    this.telefono,
  });

  /// Calcula los días hasta el próximo cumpleaños
  int get diasHastaCumpleanos {
    final now = DateTime.now();
    final thisYearBirthday = DateTime(
      now.year,
      fechaNacimiento.month,
      fechaNacimiento.day,
    );
    
    if (thisYearBirthday.isBefore(now)) {
      // Si ya pasó este año, calcular para el próximo año
      final nextYearBirthday = DateTime(
        now.year + 1,
        fechaNacimiento.month,
        fechaNacimiento.day,
      );
      return nextYearBirthday.difference(now).inDays;
    } else {
      return thisYearBirthday.difference(now).inDays;
    }
  }

  /// Obtiene el próximo cumpleaños
  DateTime get proximoCumpleanos {
    final now = DateTime.now();
    final thisYearBirthday = DateTime(
      now.year,
      fechaNacimiento.month,
      fechaNacimiento.day,
    );
    
    if (thisYearBirthday.isBefore(now)) {
      return DateTime(
        now.year + 1,
        fechaNacimiento.month,
        fechaNacimiento.day,
      );
    } else {
      return thisYearBirthday;
    }
  }

  /// Calcula la edad que cumplirá
  int get edadQueCumple {
    final now = DateTime.now();
    int edad = now.year - fechaNacimiento.year;
    
    // Si el cumpleaños no ha ocurrido este año, calcular edad para el próximo
    final thisYearBirthday = DateTime(
      now.year,
      fechaNacimiento.month,
      fechaNacimiento.day,
    );
    
    if (thisYearBirthday.isAfter(now)) {
      return edad;
    } else {
      return edad + 1;
    }
  }
}

/// Servicio para gestión de cumpleaños y automatización
class BirthdayService {
  static final BirthdayService _instance = BirthdayService._internal();
  factory BirthdayService() => _instance;
  BirthdayService._internal();

  final _clienteRepo = ClienteRepository();
  final _familiarRepo = FamiliarRepository();
  final _notificationService = NotificationService();

  /// Obtiene todos los cumpleaños del mes actual
  Future<List<BirthdayInfo>> getBirthdaysThisMonth() async {
    final now = DateTime.now();
    final birthdays = <BirthdayInfo>[];

    // Obtener clientes con cumpleaños este mes
    final clientes = await _clienteRepo.getAll();
    for (final cliente in clientes) {
      // Nota: El modelo Cliente no tiene fecha de nacimiento por defecto
      // Se podría agregar en el futuro
    }

    // Obtener familiares con cumpleaños este mes
    final familiares = await _familiarRepo.getAll();
    for (final familiar in familiares) {
      if (familiar.fechaNacimiento != null) {
        final fechaNac = familiar.fechaNacimiento!;
        if (fechaNac.month == now.month) {
          // Obtener información del cliente asociado
          final cliente = await _clienteRepo.getById(familiar.clienteId);
          
          birthdays.add(BirthdayInfo(
            id: familiar.id!,
            nombre: familiar.nombre,
            fechaNacimiento: fechaNac,
            tipo: 'familiar',
            clienteId: familiar.clienteId,
            clienteNombre: cliente?.nombre,
            telefono: cliente?.telefono,
          ));
        }
      }
    }

    // Ordenar por día del mes
    birthdays.sort((a, b) => a.fechaNacimiento.day.compareTo(b.fechaNacimiento.day));

    return birthdays;
  }

  /// Obtiene cumpleaños de los próximos N días
  Future<List<BirthdayInfo>> getUpcomingBirthdays({int days = 30}) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    final birthdays = <BirthdayInfo>[];

    // Obtener familiares
    final familiares = await _familiarRepo.getAll();
    for (final familiar in familiares) {
      if (familiar.fechaNacimiento != null) {
        final info = BirthdayInfo(
          id: familiar.id!,
          nombre: familiar.nombre,
          fechaNacimiento: familiar.fechaNacimiento!,
          tipo: 'familiar',
          clienteId: familiar.clienteId,
          clienteNombre: null,
          telefono: null,
        );

        // Verificar si el cumpleaños está en el rango
        if (info.diasHastaCumpleanos <= days) {
          // Obtener información del cliente
          final cliente = await _clienteRepo.getById(familiar.clienteId);
          birthdays.add(BirthdayInfo(
            id: info.id,
            nombre: info.nombre,
            fechaNacimiento: info.fechaNacimiento,
            tipo: info.tipo,
            clienteId: info.clienteId,
            clienteNombre: cliente?.nombre,
            telefono: cliente?.telefono,
          ));
        }
      }
    }

    // Ordenar por días hasta cumpleaños
    birthdays.sort((a, b) => a.diasHastaCumpleanos.compareTo(b.diasHastaCumpleanos));

    return birthdays;
  }

  /// Programa notificaciones para cumpleaños próximos
  Future<void> scheduleBirthdayNotifications({int daysInAdvance = 7}) async {
    try {
      final birthdays = await getUpcomingBirthdays(days: 60);
      
      for (final birthday in birthdays) {
        // Programar notificación X días antes
        await _notificationService.scheduleBirthdayReminder(
          id: birthday.id,
          name: birthday.nombre,
          birthdayDate: birthday.proximoCumpleanos,
          daysBeforeToNotify: daysInAdvance,
        );
      }

      debugPrint('✅ ${birthdays.length} notificaciones de cumpleaños programadas');
    } catch (e) {
      debugPrint('❌ Error al programar notificaciones de cumpleaños: $e');
    }
  }

  /// Envía notificación de cumpleaños del mes
  Future<void> sendMonthlyBirthdayNotification() async {
    try {
      final birthdays = await getBirthdaysThisMonth();
      
      if (birthdays.isEmpty) {
        debugPrint('ℹ️ No hay cumpleaños este mes');
        return;
      }

      // Crear mensaje con todos los cumpleaños
      final names = birthdays.take(5).map((b) => b.nombre).join(', ');
      final moreCount = birthdays.length > 5 ? ' y ${birthdays.length - 5} más' : '';
      
      await _notificationService.showInstantNotification(
        id: 99999,
        title: '🎂 Cumpleaños del mes',
        body: '$names$moreCount tienen cumpleaños este mes',
        channelId: 'birthdays',
        payload: 'birthdays_month',
      );

      debugPrint('✅ Notificación mensual de cumpleaños enviada');
    } catch (e) {
      debugPrint('❌ Error al enviar notificación mensual: $e');
    }
  }

  /// Obtiene URL para llamar por teléfono
  String getCallUrl(String telefono) {
    return 'tel:$telefono';
  }

  /// Obtiene URL para enviar WhatsApp
  String getWhatsAppUrl(String telefono, String mensaje) {
    // Limpiar teléfono (quitar espacios, guiones, etc)
    final cleanPhone = telefono.replaceAll(RegExp(r'[^\d+]'), '');
    final encodedMessage = Uri.encodeComponent(mensaje);
    return 'https://wa.me/$cleanPhone?text=$encodedMessage';
  }

  /// Genera mensaje de cumpleaños personalizado
  String getBirthdayMessage(BirthdayInfo birthday) {
    return '¡Hola! 🎂 Solo quería recordarte que pronto es el cumpleaños de ${birthday.nombre}. '
           '¿Te gustaría hacer un pedido especial? ¡Estamos para ayudarte!';
  }

  /// Verifica si hay cumpleaños hoy
  Future<List<BirthdayInfo>> getBirthdaysToday() async {
    final now = DateTime.now();
    final birthdays = <BirthdayInfo>[];

    final familiares = await _familiarRepo.getAll();
    for (final familiar in familiares) {
      if (familiar.fechaNacimiento != null) {
        final fechaNac = familiar.fechaNacimiento!;
        if (fechaNac.month == now.month && fechaNac.day == now.day) {
          final cliente = await _clienteRepo.getById(familiar.clienteId);
          birthdays.add(BirthdayInfo(
            id: familiar.id!,
            nombre: familiar.nombre,
            fechaNacimiento: fechaNac,
            tipo: 'familiar',
            clienteId: familiar.clienteId,
            clienteNombre: cliente?.nombre,
            telefono: cliente?.telefono,
          ));
        }
      }
    }

    return birthdays;
  }

  /// Envía notificación de cumpleaños de hoy
  Future<void> sendTodayBirthdayNotification() async {
    try {
      final birthdays = await getBirthdaysToday();
      
      if (birthdays.isEmpty) {
        return;
      }

      for (final birthday in birthdays) {
        await _notificationService.showInstantNotification(
          id: 50000 + birthday.id,
          title: '🎉 ¡Hoy es el cumpleaños!',
          body: '${birthday.nombre} cumple años hoy. ¡No olvides felicitarlo!',
          channelId: 'birthdays',
          payload: 'birthday_today_${birthday.id}',
        );
      }

      debugPrint('✅ ${birthdays.length} notificaciones de cumpleaños de hoy enviadas');
    } catch (e) {
      debugPrint('❌ Error al enviar notificaciones de hoy: $e');
    }
  }

  /// Obtiene estadísticas de cumpleaños
  Future<Map<String, int>> getBirthdayStats() async {
    final familiares = await _familiarRepo.getAll();
    
    final withBirthday = familiares.where((f) => f.fechaNacimiento != null).length;
    final thisMonth = (await getBirthdaysThisMonth()).length;
    final upcoming = (await getUpcomingBirthdays(days: 30)).length;
    
    return {
      'total': familiares.length,
      'with_birthday': withBirthday,
      'this_month': thisMonth,
      'next_30_days': upcoming,
    };
  }
}
