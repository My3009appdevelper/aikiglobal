import '../common/json_object_codec.dart';
import '../local/app_database.dart';

class AppNotificationDispatch {
  const AppNotificationDispatch({
    required this.uuidNotificationDispatch,
    required this.uuidNotificationEvent,
    required this.triggerSource,
    required this.idempotencyKey,
    required this.titleSnapshot,
    required this.bodySnapshot,
    required this.categorySnapshot,
    required this.audienceTypeSnapshot,
    required this.actionTypeSnapshot,
    required this.actionPayloadSnapshot,
    required this.status,
    required this.targetProfileCount,
    required this.targetDeviceCount,
    required this.successDeviceCount,
    required this.failureDeviceCount,
    required this.invalidTokenCount,
    required this.createdAt,
    required this.updatedAt,
    this.uuidTriggeredByProfile,
    this.sourceEntityType,
    this.sourceEntityUuid,
    this.startedAt,
    this.completedAt,
    this.errorSummary,
    this.deletedAt,
    this.syncedAt,
  });

  factory AppNotificationDispatch.fromLocal(LocalNotificationDispatch value) {
    return AppNotificationDispatch(
      uuidNotificationDispatch: value.uuidNotificationDispatch,
      uuidNotificationEvent: value.uuidNotificationEvent,
      triggerSource: value.triggerSource,
      uuidTriggeredByProfile: value.uuidTriggeredByProfile,
      sourceEntityType: value.sourceEntityType,
      sourceEntityUuid: value.sourceEntityUuid,
      idempotencyKey: value.idempotencyKey,
      titleSnapshot: value.titleSnapshot,
      bodySnapshot: value.bodySnapshot,
      categorySnapshot: value.categorySnapshot,
      audienceTypeSnapshot: value.audienceTypeSnapshot,
      actionTypeSnapshot: value.actionTypeSnapshot,
      actionPayloadSnapshot: decodeJsonObject(value.actionPayloadSnapshotJson),
      status: value.status,
      targetProfileCount: value.targetProfileCount,
      targetDeviceCount: value.targetDeviceCount,
      successDeviceCount: value.successDeviceCount,
      failureDeviceCount: value.failureDeviceCount,
      invalidTokenCount: value.invalidTokenCount,
      startedAt: value.startedAt,
      completedAt: value.completedAt,
      errorSummary: value.errorSummary,
      createdAt: value.createdAt,
      updatedAt: value.updatedAt,
      deletedAt: value.deletedAt,
      syncedAt: value.syncedAt,
    );
  }

  final String uuidNotificationDispatch;
  final String uuidNotificationEvent;
  final String triggerSource;
  final String? uuidTriggeredByProfile;
  final String? sourceEntityType;
  final String? sourceEntityUuid;
  final String idempotencyKey;
  final String titleSnapshot;
  final String bodySnapshot;
  final String categorySnapshot;
  final String audienceTypeSnapshot;
  final String actionTypeSnapshot;
  final Map<String, dynamic> actionPayloadSnapshot;
  final String status;
  final int targetProfileCount;
  final int targetDeviceCount;
  final int successDeviceCount;
  final int failureDeviceCount;
  final int invalidTokenCount;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? errorSummary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  bool get isFinished =>
      const {'completed', 'partial', 'failed', 'cancelled'}.contains(status);
}
