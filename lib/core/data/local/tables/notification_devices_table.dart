// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

const notificationDevicePlatforms = ['android', 'ios', 'web'];
const notificationPermissionStatuses = [
  'authorized',
  'denied',
  'not_determined',
  'provisional',
];

@DataClassName('LocalNotificationDevice')
class NotificationDevicesTable extends Table {
  @override
  String get tableName => 'local_notification_devices';

  TextColumn get uuidNotificationDevice =>
      text().named('uuid_notification_device')();
  TextColumn get uuidProfile => text().named('uuid_profile')();
  TextColumn get installationId => text().named('installation_id')();
  TextColumn get fcmToken => text().named('fcm_token').nullable()();
  TextColumn get platform =>
      text().check(platform.isIn(notificationDevicePlatforms))();
  TextColumn get permissionStatus => text()
      .named('permission_status')
      .check(permissionStatus.isIn(notificationPermissionStatuses))
      .withDefault(const Constant('not_determined'))();
  TextColumn get appVersion => text().named('app_version').nullable()();
  TextColumn get timeZone => text().named('timezone').nullable()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get registrationRefreshedAt =>
      dateTime().named('registration_refreshed_at').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuidNotificationDevice};

  @override
  List<Set<Column>> get uniqueKeys => [
    {uuidProfile, installationId},
  ];
}
