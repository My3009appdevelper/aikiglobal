import '../common/json_object_codec.dart';
import '../local/app_database.dart';

class AppNotificationEvent {
  const AppNotificationEvent({
    required this.uuidNotificationEvent,
    required this.name,
    required this.category,
    required this.titleTemplate,
    required this.bodyTemplate,
    required this.triggerType,
    required this.executionMode,
    required this.audienceType,
    required this.actionType,
    required this.actionPayloadTemplate,
    this.triggerConfig = const {},
    required this.startsAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.triggerKey,
    this.endsAt,
    this.uuidCreatedByProfile,
    this.uuidUpdatedByProfile,
    this.deletedAt,
    this.syncedAt,
  });

  factory AppNotificationEvent.fromLocal(LocalNotificationEvent event) {
    return AppNotificationEvent(
      uuidNotificationEvent: event.uuidNotificationEvent,
      name: event.name,
      category: event.category,
      titleTemplate: event.titleTemplate,
      bodyTemplate: event.bodyTemplate,
      triggerType: event.triggerType,
      triggerKey: event.triggerKey,
      executionMode: event.executionMode,
      audienceType: event.audienceType,
      actionType: event.actionType,
      actionPayloadTemplate: decodeJsonObject(event.actionPayloadTemplateJson),
      triggerConfig: decodeJsonObject(event.triggerConfigJson),
      startsAt: event.startsAt,
      endsAt: event.endsAt,
      status: event.status,
      uuidCreatedByProfile: event.uuidCreatedByProfile,
      uuidUpdatedByProfile: event.uuidUpdatedByProfile,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      deletedAt: event.deletedAt,
      syncedAt: event.syncedAt,
    );
  }

  final String uuidNotificationEvent;
  final String name;
  final String category;
  final String titleTemplate;
  final String bodyTemplate;
  final String triggerType;
  final String? triggerKey;
  final String executionMode;
  final String audienceType;
  final String actionType;
  final Map<String, dynamic> actionPayloadTemplate;
  final Map<String, dynamic> triggerConfig;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String status;
  final String? uuidCreatedByProfile;
  final String? uuidUpdatedByProfile;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  bool isActiveAt(DateTime date) {
    final utcDate = date.toUtc();
    final utcEndsAt = endsAt?.toUtc();
    return deletedAt == null &&
        status == 'active' &&
        !utcDate.isBefore(startsAt.toUtc()) &&
        (utcEndsAt == null || !utcDate.isAfter(utcEndsAt));
  }

  bool get hasPendingSync =>
      syncedAt == null || syncedAt!.toUtc().isBefore(updatedAt.toUtc());
}
