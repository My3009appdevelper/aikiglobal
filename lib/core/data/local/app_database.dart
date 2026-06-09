import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/content_items_table.dart';
import 'tables/profiles_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [ProfilesTable, ContentItemsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'aiki_local_database');
  }
}
