// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../../models/notification_values.dart';

@DataClassName('LocalNotificationEvent')
class NotificationEventsTable extends Table {
  @override
  String get tableName => 'local_notification_events';

  TextColumn get uuidNotificationEvent =>
      text().named('uuid_notification_event')();
  TextColumn get name => text()();
  TextColumn get category =>
      text().check(category.isIn(notificationCategories))();
  TextColumn get titleTemplate => text().named('title_template')();
  TextColumn get bodyTemplate => text().named('body_template')();
  TextColumn get triggerType => text()
      .named('trigger_type')
      .check(triggerType.isIn(notificationEventTriggerTypes))();
  TextColumn get triggerKey => text().named('trigger_key').nullable()();
  TextColumn get executionMode => text()
      .named('execution_mode')
      .check(executionMode.isIn(notificationEventExecutionModes))();
  TextColumn get audienceType => text()
      .named('audience_type')
      .check(audienceType.isIn(notificationAudienceTypes))();
  TextColumn get actionType => text()
      .named('action_type')
      .check(actionType.isIn(notificationActionTypes))();
  TextColumn get actionPayloadTemplateJson => text()
      .named('action_payload_template')
      .withDefault(const Constant('{}'))();
  TextColumn get triggerConfigJson =>
      text().named('trigger_config').withDefault(const Constant('{}'))();
  DateTimeColumn get startsAt =>
      dateTime().named('starts_at').withDefault(currentDateAndTime)();
  DateTimeColumn get endsAt => dateTime().named('ends_at').nullable()();
  TextColumn get status => text()
      .check(status.isIn(notificationEventStatuses))
      .withDefault(const Constant('draft'))();
  TextColumn get uuidCreatedByProfile =>
      text().named('uuid_created_by_profile').nullable()();
  TextColumn get uuidUpdatedByProfile =>
      text().named('uuid_updated_by_profile').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuidNotificationEvent};
}
