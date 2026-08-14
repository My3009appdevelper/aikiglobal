class AppSubscriptionProduct {
  const AppSubscriptionProduct({
    required this.uuidSubscriptionProduct,
    required this.codigo,
    required this.nombre,
    required this.incluyeDescargas,
    required this.activo,
    required this.orden,
    required this.createdAt,
    required this.updatedAt,
    this.descripcion,
    this.deletedAt,
  });

  factory AppSubscriptionProduct.fromJson(Map<String, dynamic> json) {
    return AppSubscriptionProduct(
      uuidSubscriptionProduct: _requiredText(json, 'uuid_subscription_product'),
      codigo: _requiredText(json, 'codigo'),
      nombre: _requiredText(json, 'nombre'),
      descripcion: _nullableText(json['descripcion']),
      incluyeDescargas: _boolValue(json['incluye_descargas']),
      activo: _boolValue(json['activo'], fallback: false),
      orden: _intValue(json['orden']),
      createdAt: _dateValue(json['created_at']),
      updatedAt: _dateValue(json['updated_at']),
      deletedAt: _nullableDateValue(json['deleted_at']),
    );
  }

  final String uuidSubscriptionProduct;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final bool incluyeDescargas;
  final bool activo;
  final int orden;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isAvailable => activo && deletedAt == null;
}

class AppUserSubscription {
  const AppUserSubscription({
    required this.uuidUserSubscription,
    required this.uuidProfile,
    required this.uuidSubscriptionProduct,
    required this.source,
    required this.status,
    required this.startedAt,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.autoRenew,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.externalSubscriptionId,
    this.deletedAt,
  });

  factory AppUserSubscription.fromJson(Map<String, dynamic> json) {
    return AppUserSubscription(
      uuidUserSubscription: _requiredText(json, 'uuid_user_subscription'),
      uuidProfile: _requiredText(json, 'uuid_profile'),
      uuidSubscriptionProduct: _requiredText(json, 'uuid_subscription_product'),
      source: _requiredText(json, 'source'),
      status: _requiredText(json, 'status'),
      startedAt: _nullableDateValue(json['started_at']),
      currentPeriodStart: _nullableDateValue(json['current_period_start']),
      currentPeriodEnd: _nullableDateValue(json['current_period_end']),
      autoRenew: _boolValue(json['auto_renew']),
      cancelledAt: _nullableDateValue(json['cancelled_at']),
      externalSubscriptionId: _nullableText(json['external_subscription_id']),
      createdAt: _dateValue(json['created_at']),
      updatedAt: _dateValue(json['updated_at']),
      deletedAt: _nullableDateValue(json['deleted_at']),
    );
  }

  final String uuidUserSubscription;
  final String uuidProfile;
  final String uuidSubscriptionProduct;
  final String source;
  final String status;
  final DateTime? startedAt;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool autoRenew;
  final DateTime? cancelledAt;
  final String? externalSubscriptionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get hasPremiumAccess {
    final periodEnd = currentPeriodEnd;
    if (deletedAt != null || status != 'active') {
      return false;
    }

    if (periodEnd == null) {
      return true;
    }

    return periodEnd.isAfter(DateTime.now().toUtc());
  }
}

String _requiredText(Map<String, dynamic> json, String key) {
  final value = json[key]?.toString().trim();
  if (value == null || value.isEmpty) {
    throw FormatException('Falta el campo $key.');
  }
  return value;
}

String? _nullableText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

bool _boolValue(Object? value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  return fallback;
}

int _intValue(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime _dateValue(Object? value) {
  return _nullableDateValue(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? _nullableDateValue(Object? value) {
  if (value is DateTime) {
    return value.toUtc();
  }
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text)?.toUtc();
}
