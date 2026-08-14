class ManualNotificationAudiencePreview {
  const ManualNotificationAudiencePreview({
    required this.uuidNotificationEvent,
    required this.title,
    required this.body,
    required this.category,
    required this.audienceType,
    required this.actionType,
    required this.actionPayload,
    required this.targetProfileCount,
    required this.targetDeviceCount,
  });

  factory ManualNotificationAudiencePreview.fromJson(
    Map<String, dynamic> json, {
    required String expectedEventUuid,
  }) {
    return ManualNotificationAudiencePreview(
      uuidNotificationEvent: _requiredMatchingEventUuid(
        json['uuid_notification_event'],
        expectedEventUuid,
      ),
      title: _requiredText(json['title']),
      body: _requiredText(json['body']),
      category: _requiredText(json['category']),
      audienceType: _requiredText(json['audience_type']),
      actionType: _requiredText(json['action_type']),
      actionPayload: _requiredObject(json['action_payload']),
      targetProfileCount: _requiredCount(json['target_profile_count']),
      targetDeviceCount: _requiredCount(json['target_device_count']),
    );
  }

  final String uuidNotificationEvent;
  final String title;
  final String body;
  final String category;
  final String audienceType;
  final String actionType;
  final Map<String, dynamic> actionPayload;
  final int targetProfileCount;
  final int targetDeviceCount;
}

class ManualNotificationDispatchAcceptance {
  const ManualNotificationDispatchAcceptance({
    required this.uuidNotificationEvent,
    required this.uuidNotificationDispatch,
    required this.status,
    required this.targetProfileCount,
    required this.targetDeviceCount,
    required this.reused,
    this.sourceDispatchUuid,
  });

  factory ManualNotificationDispatchAcceptance.fromJson(
    Map<String, dynamic> json, {
    required String expectedEventUuid,
  }) {
    return ManualNotificationDispatchAcceptance(
      uuidNotificationEvent: _requiredMatchingEventUuid(
        json['uuid_notification_event'],
        expectedEventUuid,
      ),
      uuidNotificationDispatch: _requiredText(
        json['uuid_notification_dispatch'],
      ),
      status: _requiredText(json['status']),
      targetProfileCount: _requiredCount(json['target_profile_count']),
      targetDeviceCount: _requiredCount(json['target_device_count']),
      reused: _requiredBool(json['reused']),
      sourceDispatchUuid: _nullableText(json['source_dispatch_uuid']),
    );
  }

  final String uuidNotificationEvent;
  final String uuidNotificationDispatch;
  final String status;
  final int targetProfileCount;
  final int targetDeviceCount;
  final bool reused;
  final String? sourceDispatchUuid;
}

Map<String, dynamic> _requiredObject(Object? value) {
  if (value is Map) {
    return Map.unmodifiable(Map<String, dynamic>.from(value));
  }
  throw const FormatException(
    'La respuesta de notificaciones es inv\u00e1lida.',
  );
}

bool _requiredBool(Object? value) {
  if (value is bool) {
    return value;
  }
  throw const FormatException(
    'La respuesta de notificaciones es inv\u00e1lida.',
  );
}

String _requiredMatchingEventUuid(Object? value, String expectedEventUuid) {
  final eventUuid = _requiredText(value);
  if (eventUuid != expectedEventUuid) {
    throw const FormatException(
      'La respuesta de notificaciones es inv\u00e1lida.',
    );
  }
  return eventUuid;
}

String _requiredText(Object? value) {
  final text = value?.toString().trim();
  if (text != null && text.isNotEmpty) {
    return text;
  }
  throw const FormatException(
    'La respuesta de notificaciones es inv\u00e1lida.',
  );
}

String? _nullableText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
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
    'La respuesta de notificaciones es inv\u00e1lida.',
  );
}
