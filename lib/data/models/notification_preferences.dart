/// Modelo para preferencias de notificaciones
/// Almacena la configuración del usuario para diferentes tipos de notificaciones
class NotificationPreferences {
  // Notificaciones de entrega
  final bool deliveryEnabled;
  final int deliveryDaysBefore;
  final String deliveryTime;

  // Notificaciones de preparación
  final bool preparationEnabled;
  final int preparationDaysBefore;
  final String preparationTime;

  // Notificaciones de cumpleaños
  final bool birthdayEnabled;
  final int birthdayDaysBefore;
  final String birthdayTime;
  final bool birthdayMonthlyEnabled;

  // Notificaciones post-venta
  final bool postSaleEnabled;
  final int postSaleDaysAfter;
  final String postSaleTime;

  NotificationPreferences({
    this.deliveryEnabled = true,
    this.deliveryDaysBefore = 1,
    this.deliveryTime = '09:00',
    this.preparationEnabled = true,
    this.preparationDaysBefore = 1,
    this.preparationTime = '08:00',
    this.birthdayEnabled = true,
    this.birthdayDaysBefore = 7,
    this.birthdayTime = '10:00',
    this.birthdayMonthlyEnabled = true,
    this.postSaleEnabled = true,
    this.postSaleDaysAfter = 2,
    this.postSaleTime = '18:00',
  });

  /// Convierte el objeto a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'delivery_enabled': deliveryEnabled ? 1 : 0,
      'delivery_days_before': deliveryDaysBefore,
      'delivery_time': deliveryTime,
      'preparation_enabled': preparationEnabled ? 1 : 0,
      'preparation_days_before': preparationDaysBefore,
      'preparation_time': preparationTime,
      'birthday_enabled': birthdayEnabled ? 1 : 0,
      'birthday_days_before': birthdayDaysBefore,
      'birthday_time': birthdayTime,
      'birthday_monthly_enabled': birthdayMonthlyEnabled ? 1 : 0,
      'post_sale_enabled': postSaleEnabled ? 1 : 0,
      'post_sale_days_after': postSaleDaysAfter,
      'post_sale_time': postSaleTime,
    };
  }

  /// Crea un objeto desde un Map
  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      deliveryEnabled: (map['delivery_enabled'] as int?) == 1,
      deliveryDaysBefore: (map['delivery_days_before'] as int?) ?? 1,
      deliveryTime: (map['delivery_time'] as String?) ?? '09:00',
      preparationEnabled: (map['preparation_enabled'] as int?) == 1,
      preparationDaysBefore: (map['preparation_days_before'] as int?) ?? 1,
      preparationTime: (map['preparation_time'] as String?) ?? '08:00',
      birthdayEnabled: (map['birthday_enabled'] as int?) == 1,
      birthdayDaysBefore: (map['birthday_days_before'] as int?) ?? 7,
      birthdayTime: (map['birthday_time'] as String?) ?? '10:00',
      birthdayMonthlyEnabled: (map['birthday_monthly_enabled'] as int?) == 1,
      postSaleEnabled: (map['post_sale_enabled'] as int?) == 1,
      postSaleDaysAfter: (map['post_sale_days_after'] as int?) ?? 2,
      postSaleTime: (map['post_sale_time'] as String?) ?? '18:00',
    );
  }

  /// Crea una copia con algunos campos modificados
  NotificationPreferences copyWith({
    bool? deliveryEnabled,
    int? deliveryDaysBefore,
    String? deliveryTime,
    bool? preparationEnabled,
    int? preparationDaysBefore,
    String? preparationTime,
    bool? birthdayEnabled,
    int? birthdayDaysBefore,
    String? birthdayTime,
    bool? birthdayMonthlyEnabled,
    bool? postSaleEnabled,
    int? postSaleDaysAfter,
    String? postSaleTime,
  }) {
    return NotificationPreferences(
      deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
      deliveryDaysBefore: deliveryDaysBefore ?? this.deliveryDaysBefore,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      preparationEnabled: preparationEnabled ?? this.preparationEnabled,
      preparationDaysBefore: preparationDaysBefore ?? this.preparationDaysBefore,
      preparationTime: preparationTime ?? this.preparationTime,
      birthdayEnabled: birthdayEnabled ?? this.birthdayEnabled,
      birthdayDaysBefore: birthdayDaysBefore ?? this.birthdayDaysBefore,
      birthdayTime: birthdayTime ?? this.birthdayTime,
      birthdayMonthlyEnabled: birthdayMonthlyEnabled ?? this.birthdayMonthlyEnabled,
      postSaleEnabled: postSaleEnabled ?? this.postSaleEnabled,
      postSaleDaysAfter: postSaleDaysAfter ?? this.postSaleDaysAfter,
      postSaleTime: postSaleTime ?? this.postSaleTime,
    );
  }

  @override
  String toString() {
    return 'NotificationPreferences{deliveryEnabled: $deliveryEnabled, birthdayEnabled: $birthdayEnabled}';
  }
}
