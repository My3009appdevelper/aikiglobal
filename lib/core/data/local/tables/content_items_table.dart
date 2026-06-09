import 'package:drift/drift.dart';

@DataClassName('LocalContentItem')
class ContentItemsTable extends Table {
  @override
  String get tableName => 'local_content_items';

  TextColumn get uuidContentItem => text().named('uuid_content_item')();
  TextColumn get tipo => text()();
  TextColumn get titulo => text()();
  TextColumn get subtitulo => text().nullable()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get coverPathSupabase =>
      text().named('cover_path_supabase').nullable()();
  TextColumn get coverPathLocal =>
      text().named('cover_path_local').nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  BoolColumn get destacado => boolean().withDefault(const Constant(false))();
  BoolColumn get descargable => boolean().withDefault(const Constant(false))();
  IntColumn get duracionSegundos =>
      integer().named('duracion_segundos').nullable()();
  IntColumn get orden => integer().withDefault(const Constant(0))();
  TextColumn get createdBy => text().named('created_by').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuidContentItem};
}
