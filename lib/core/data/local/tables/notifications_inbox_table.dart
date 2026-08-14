// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../../models/notification_values.dart';

@DataClassName('LocalNotificationInboxItem')
class NotificationsInboxTable extends Table {
  @override
  String get tableName => 'local_notifications_inbox';

  TextColumn get uuidNotificationInbox =>
      text().named('uuid_notification_inbox')();
  TextColumn get uuidNotificationDispatch =>
      text().named('uuid_notification_dispatch')();
  TextColumn get uuidProfile => text().named('uuid_profile')();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get category =>
      text().check(category.isIn(notificationCategories))();
  TextColumn get actionType => text()
      .named('action_type')
      .check(actionType.isIn(notificationActionTypes))();
  TextColumn get actionPayloadJson =>
      text().named('action_payload').withDefault(const Constant('{}'))();
  DateTimeColumn get readAt => dateTime().named('read_at').nullable()();
  DateTimeColumn get openedAt => dateTime().named('opened_at').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuidNotificationInbox};

  @override
  List<Set<Column>> get uniqueKeys => [
    {uuidNotificationDispatch, uuidProfile},
  ];
}
