import 'package:drift/drift.dart';

@DataClassName('LocalContentMedia')
class ContentMediaTable extends Table {
  @override
  String get tableName => 'local_content_media';

  TextColumn get uuidContentMedia => text().named('uuid_content_media')();
  TextColumn get uuidContentItem => text().named('uuid_content_item')();
  TextColumn get tipo => text().named('type')();
  TextColumn get titulo => text().named('title').nullable()();
  TextColumn get storagePathSupabase => text().named('storage_path')();
  TextColumn get storagePathLocal =>
      text().named('storage_path_local').nullable()();
  IntColumn get duracionSegundos =>
      integer().named('duration_seconds').nullable()();
  IntColumn get orden =>
      integer().named('sort_order').withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuidContentMedia};
}
