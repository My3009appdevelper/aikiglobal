import 'package:drift/drift.dart';

@DataClassName('LocalContentDownload')
class ContentDownloadsTable extends Table {
  @override
  String get tableName => 'local_content_downloads';

  TextColumn get uuidContentDownload => text().named('uuid_content_download')();
  TextColumn get uuidProfile => text().named('uuid_profile')();
  TextColumn get uuidContentItem => text().named('uuid_content_item')();
  TextColumn get uuidContentMedia => text().named('uuid_content_media')();
  TextColumn get storagePathSupabase => text().named('storage_path_supabase')();
  TextColumn get storagePathLocal =>
      text().named('storage_path_local').nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get bytesDownloaded =>
      integer().named('bytes_downloaded').withDefault(const Constant(0))();
  IntColumn get totalBytes =>
      integer().named('total_bytes').withDefault(const Constant(0))();
  DateTimeColumn get downloadedAt =>
      dateTime().named('downloaded_at').nullable()();
  DateTimeColumn get accessExpiresAt =>
      dateTime().named('access_expires_at').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {uuidContentDownload};

  @override
  List<Set<Column>> get uniqueKeys => [
    {uuidProfile, uuidContentMedia},
  ];
}
