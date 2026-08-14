// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../../models/notification_values.dart';

@DataClassName('LocalNotificationDispatch')
class NotificationDispatchesTable extends Table {
  @override
  String get tableName => 'local_notification_dispatches';

  TextColumn get uuidNotificationDispatch =>
      text().named('uuid_notification_dispatch')();
  TextColumn get uuidNotificationEvent =>
      text().named('uuid_notification_event')();
  TextColumn get triggerSource => text()
      .named('trigger_source')
      .check(triggerSource.isIn(notificationDispatchTriggerSources))();
  TextColumn get uuidTriggeredByProfile =>
      text().named('uuid_triggered_by_profile').nullable()();
  TextColumn get sourceEntityType =>
      text().named('source_entity_type').nullable()();
  TextColumn get sourceEntityUuid =>
      text().named('source_entity_uuid').nullable()();
  TextColumn get idempotencyKey =>
      text().named('idempotency_key').unique()();
  TextColumn get titleSnapshot => text().named('title_snapshot')();
  TextColumn get bodySnapshot => text().named('body_snapshot')();
  TextColumn get categorySnapshot => text()
      .named('category_snapshot')
      .check(categorySnapshot.isIn(notificationCategories))();
  TextColumn get audienceTypeSnapshot => text()
      .named('audience_type_snapshot')
      .check(audienceTypeSnapshot.isIn(notificationAudienceTypes))();
  TextColumn get actionTypeSnapshot => text()
      .named('action_type_snapshot')
      .check(actionTypeSnapshot.isIn(notificationActionTypes))();
  TextColumn get actionPayloadSnapshotJson => text()
      .named('action_payload_snapshot')
      .withDefault(const Constant('{}'))();
  TextColumn get status => text()
      .check(status.isIn(notificationDispatchStatuses))
      .withDefault(const Constant('pending'))();
  IntColumn get targetProfileCount => integer()
      .named('target_profile_count')
      .check(targetProfileCount.isBiggerOrEqualValue(0))
      .withDefault(const Constant(0))();
  IntColumn get targetDeviceCount => integer()
      .named('target_device_count')
      .check(targetDeviceCount.isBiggerOrEqualValue(0))
      .withDefault(const Constant(0))();
  IntColumn get successDeviceCount => integer()
      .named('success_device_count')
      .check(successDeviceCount.isBiggerOrEqualValue(0))
      .withDefault(const Constant(0))();
  IntColumn get failureDeviceCount => integer()
      .named('failure_device_count')
      .check(failureDeviceCount.isBiggerOrEqualValue(0))
      .withDefault(const Constant(0))();
  IntColumn get invalidTokenCount => integer()
      .named('invalid_token_count')
      .check(invalidTokenCount.isBiggerOrEqualValue(0))
      .withDefault(const Constant(0))();
  DateTimeColumn get startedAt => dateTime().named('started_at').nullable()();
  DateTimeColumn get completedAt =>
      dateTime().named('completed_at').nullable()();
  TextColumn get errorSummary => text().named('error_summary').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuidNotificationDispatch};
}
