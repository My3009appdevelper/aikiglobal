// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

@DataClassName('LocalWellnessDailyLog')
class WellnessDailyLogsTable extends Table {
  @override
  String get tableName => 'local_wellness_daily_logs';

  TextColumn get uuidDailyLog => text().named('uuid_daily_log')();
  TextColumn get uuidProfile => text().named('uuid_profile')();
  TextColumn get fecha => text()();
  TextColumn get mood => text().nullable()();
  IntColumn get energia => integer()
      .check(energia.isBetweenValues(0, 5))
      .withDefault(const Constant(0))();
  IntColumn get calma => integer()
      .check(calma.isBetweenValues(0, 5))
      .withDefault(const Constant(0))();
  IntColumn get descanso => integer()
      .check(descanso.isBetweenValues(0, 5))
      .withDefault(const Constant(0))();
  IntColumn get conexion => integer()
      .check(conexion.isBetweenValues(0, 5))
      .withDefault(const Constant(0))();
  BoolColumn get meditacionCompletada => boolean()
      .named('meditacion_completada')
      .withDefault(const Constant(false))();
  IntColumn get minutosBienestar => integer()
      .named('minutos_bienestar')
      .check(minutosBienestar.isBiggerOrEqualValue(0))
      .withDefault(const Constant(0))();
  TextColumn get nota => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuidDailyLog};

  @override
  List<Set<Column>> get uniqueKeys => [
    {uuidProfile, fecha},
  ];
}
