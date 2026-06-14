// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

@DataClassName('LocalWellnessProfileStats')
class WellnessProfileStatsTable extends Table {
  @override
  String get tableName => 'local_wellness_profile_stats';

  TextColumn get uuidProfile => text().named('uuid_profile')();
  IntColumn get currentStreak => integer()
      .named('current_streak')
      .check(currentStreak.isBiggerOrEqualValue(0))
      .withDefault(const Constant(0))();
  IntColumn get longestStreak => integer()
      .named('longest_streak')
      .check(longestStreak.isBiggerOrEqualValue(0))
      .withDefault(const Constant(0))();
  TextColumn get lastActivityDate =>
      text().named('last_activity_date').nullable()();
  IntColumn get totalActiveDays => integer()
      .named('total_active_days')
      .check(totalActiveDays.isBiggerOrEqualValue(0))
      .withDefault(const Constant(0))();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuidProfile};
}
