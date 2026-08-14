class NotificationDispatchAnalytics {
  const NotificationDispatchAnalytics({
    required this.uuidNotificationDispatch,
    required this.targetProfileCount,
    required this.targetDeviceCount,
    required this.successDeviceCount,
    required this.failureDeviceCount,
    required this.invalidTokenCount,
    required this.inboxCount,
    required this.openedCount,
    required this.readCount,
    required this.recipients,
  });

  factory NotificationDispatchAnalytics.fromJson(
    Map<String, dynamic> json, {
    required String expectedDispatchUuid,
  }) {
    final dispatchUuid = _requiredText(json['uuid_notification_dispatch']);
    if (dispatchUuid != expectedDispatchUuid) {
      throw const FormatException(
        'La respuesta de analítica de notificaciones es inválida.',
      );
    }
    final recipientsValue = json['recipients'];
    if (recipientsValue is! List) {
      throw const FormatException(
        'La respuesta de analítica de notificaciones es inválida.',
      );
    }

    return NotificationDispatchAnalytics(
      uuidNotificationDispatch: dispatchUuid,
      targetProfileCount: _requiredCount(json['target_profile_count']),
      targetDeviceCount: _requiredCount(json['target_device_count']),
      successDeviceCount: _requiredCount(json['success_device_count']),
      failureDeviceCount: _requiredCount(json['failure_device_count']),
      invalidTokenCount: _requiredCount(json['invalid_token_count']),
      inboxCount: _requiredCount(json['inbox_count']),
      openedCount: _requiredCount(json['opened_count']),
      readCount: _requiredCount(json['read_count']),
      recipients: List.unmodifiable(
        recipientsValue.map((value) {
          if (value is! Map) {
            throw const FormatException(
              'La respuesta de analítica de notificaciones es inválida.',
            );
          }
          return NotificationDispatchRecipient.fromJson(
            Map<String, dynamic>.from(value),
          );
        }),
      ),
    );
  }

  final String uuidNotificationDispatch;
  final int targetProfileCount;
  final int targetDeviceCount;
  final int successDeviceCount;
  final int failureDeviceCount;
  final int invalidTokenCount;
  final int inboxCount;
  final int openedCount;
  final int readCount;
  final List<NotificationDispatchRecipient> recipients;

  int get notOpenedCount => (inboxCount - openedCount).clamp(0, inboxCount);

  int get notReadCount => (inboxCount - readCount).clamp(0, inboxCount);

  double get openedRate => _rate(openedCount, inboxCount);

  double get readRate => _rate(readCount, inboxCount);
}

class NotificationDispatchRecipient {
  const NotificationDispatchRecipient({
    required this.uuidProfile,
    required this.displayName,
    required this.email,
    required this.openedAt,
    required this.readAt,
  });

  factory NotificationDispatchRecipient.fromJson(Map<String, dynamic> json) {
    final openedAt = _nullableDateTime(json['opened_at']);
    final readAt = _nullableDateTime(json['read_at']);
    return NotificationDispatchRecipient(
      uuidProfile: _requiredText(json['uuid_profile']),
      displayName: _nullableText(json['display_name']),
      email: _requiredText(json['email']),
      openedAt: openedAt,
      readAt: readAt,
    );
  }

  final String uuidProfile;
  final String? displayName;
  final String email;
  final DateTime? openedAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  bool get isOpened => openedAt != null;
}

double _rate(int numerator, int denominator) {
  if (denominator <= 0) {
    return 0;
  }
  return numerator / denominator;
}

String _requiredText(Object? value) {
  final text = value?.toString().trim();
  if (text != null && text.isNotEmpty) {
    return text;
  }
  throw const FormatException(
    'La respuesta de analítica de notificaciones es inválida.',
  );
}

String? _nullableText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime? _nullableDateTime(Object? value) {
  if (value == null) {
    return null;
  }
  final parsed = DateTime.tryParse(value.toString());
  if (parsed == null) {
    throw const FormatException(
      'La respuesta de analítica de notificaciones es inválida.',
    );
  }
  return parsed.toUtc();
}

int _requiredCount(Object? value) {
  if (value is int && value >= 0) {
    return value;
  }
  if (value is num && value >= 0 && value == value.roundToDouble()) {
    return value.toInt();
  }
  final parsed = int.tryParse(value?.toString() ?? '');
  if (parsed != null && parsed >= 0) {
    return parsed;
  }
  throw const FormatException(
    'La respuesta de analítica de notificaciones es inválida.',
  );
}
