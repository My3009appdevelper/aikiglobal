import '../common/json_object_codec.dart';
import '../local/app_database.dart';

class AppNotificationInboxItem {
  const AppNotificationInboxItem({
    required this.uuidNotificationInbox,
    required this.uuidNotificationDispatch,
    required this.uuidProfile,
    required this.title,
    required this.body,
    required this.category,
    required this.actionType,
    required this.actionPayload,
    required this.createdAt,
    required this.updatedAt,
    this.readAt,
    this.openedAt,
    this.deletedAt,
    this.syncedAt,
  });

  factory AppNotificationInboxItem.fromLocal(LocalNotificationInboxItem value) {
    return AppNotificationInboxItem(
      uuidNotificationInbox: value.uuidNotificationInbox,
      uuidNotificationDispatch: value.uuidNotificationDispatch,
      uuidProfile: value.uuidProfile,
      title: value.title,
      body: value.body,
      category: value.category,
      actionType: value.actionType,
      actionPayload: decodeJsonObject(value.actionPayloadJson),
      readAt: value.readAt,
      openedAt: value.openedAt,
      createdAt: value.createdAt,
      updatedAt: value.updatedAt,
      deletedAt: value.deletedAt,
      syncedAt: value.syncedAt,
    );
  }

  final String uuidNotificationInbox;
  final String uuidNotificationDispatch;
  final String uuidProfile;
  final String title;
  final String body;
  final String category;
  final String actionType;
  final Map<String, dynamic> actionPayload;
  final DateTime? readAt;
  final DateTime? openedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  bool get isRead => readAt != null;
  bool get isOpened => openedAt != null;
  bool get hasPendingSync =>
      syncedAt == null || syncedAt!.toUtc().isBefore(updatedAt.toUtc());
}
