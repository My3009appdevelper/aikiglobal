// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

@DataClassName('LocalUserContentState')
class UserContentStatesTable extends Table {
  @override
  String get tableName => 'local_user_content_states';

  TextColumn get uuidUserContentState =>
      text().named('uuid_user_content_state')();
  TextColumn get uuidProfile => text().named('uuid_profile')();
  TextColumn get uuidContentItem => text().named('uuid_content_item')();
  BoolColumn get favorito => boolean().withDefault(const Constant(false))();
  IntColumn get progresoPorcentaje => integer()
      .named('progreso_porcentaje')
      .check(progresoPorcentaje.isBetweenValues(0, 100))
      .withDefault(const Constant(0))();
  IntColumn get ultimaPosicionSegundos => integer()
      .named('ultima_posicion_segundos')
      .check(ultimaPosicionSegundos.isBiggerOrEqualValue(0))
      .withDefault(const Constant(0))();
  BoolColumn get completado => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startedAt => dateTime().named('started_at').nullable()();
  DateTimeColumn get completedAt =>
      dateTime().named('completed_at').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuidUserContentState};

  @override
  List<Set<Column>> get uniqueKeys => [
    {uuidProfile, uuidContentItem},
  ];
}
