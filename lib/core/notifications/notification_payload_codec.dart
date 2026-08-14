import 'dart:convert';

import '../data/models/notification_values.dart';
import 'notification_message.dart';

class NotificationPayload {
  const NotificationPayload({
    required this.schemaVersion,
    required this.uuidNotificationDispatch,
    required this.uuidNotificationInbox,
    required this.category,
    required this.actionType,
    required this.actionPayload,
    required this.title,
    required this.body,
  });

  final String schemaVersion;
  final String uuidNotificationDispatch;
  final String uuidNotificationInbox;
  final String category;
  final String actionType;
  final Map<String, dynamic> actionPayload;
  final String? title;
  final String? body;
}

class NotificationPayloadCodec {
  const NotificationPayloadCodec();

  NotificationPayload? tryDecode(NotificationMessage message) {
    final data = message.data;
    if (data.values.any((value) => value is! String)) {
      return null;
    }

    final schemaVersion = _requiredString(data, 'schema_version');
    final uuidDispatch = _requiredString(data, 'uuid_notification_dispatch');
    final uuidInbox = _requiredString(data, 'uuid_notification_inbox');
    final category = _requiredString(data, 'category');
    final actionType = _requiredString(data, 'action_type');
    final actionPayloadJson = _requiredString(data, 'action_payload');

    if (schemaVersion == null ||
        schemaVersion != '1' ||
        uuidDispatch == null ||
        !_isUuid(uuidDispatch) ||
        uuidInbox == null ||
        !_isUuid(uuidInbox) ||
        category == null ||
        !notificationCategories.contains(category) ||
        actionType == null ||
        !notificationActionTypes.contains(actionType) ||
        actionPayloadJson == null) {
      return null;
    }

    final actionPayload = _tryDecodeObject(actionPayloadJson);
    if (actionPayload == null) {
      return null;
    }
    if (actionType == 'open_content_item') {
      final contentUuid = actionPayload['uuid_content_item'];
      if (contentUuid is! String || !_isUuid(contentUuid.trim())) {
        return null;
      }
    }

    return NotificationPayload(
      schemaVersion: schemaVersion,
      uuidNotificationDispatch: uuidDispatch,
      uuidNotificationInbox: uuidInbox,
      category: category,
      actionType: actionType,
      actionPayload: Map.unmodifiable(actionPayload),
      title: message.title,
      body: message.body,
    );
  }
}

final RegExp _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

bool _isUuid(String value) => _uuidPattern.hasMatch(value);

String? _requiredString(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! String) {
    return null;
  }
  final clean = value.trim();
  return clean.isEmpty ? null : clean;
}

Map<String, dynamic>? _tryDecodeObject(String value) {
  try {
    final decoded = jsonDecode(value);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}
