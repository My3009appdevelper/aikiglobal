import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'app_database_file.dart';
import 'tables/content_media_table.dart';
import 'tables/content_items_table.dart';
import 'tables/profiles_table.dart';
import 'tables/user_content_states_table.dart';
import 'tables/wellness_daily_logs_table.dart';
import 'tables/wellness_profile_stats_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ProfilesTable,
    ContentItemsTable,
    ContentMediaTable,
    UserContentStatesTable,
    WellnessDailyLogsTable,
    WellnessProfileStatsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor, bool resetLocalDatabaseOnOpen = false})
    : super(
        executor ??
            _openConnection(resetLocalDatabaseOnOpen: resetLocalDatabaseOnOpen),
      );

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(contentMediaTable);
        }
        if (from < 3) {
          await m.alterTable(TableMigration(contentMediaTable));
        }
      },
    );
  }

  static const String databaseName = 'aiki_local_database';

  static QueryExecutor _openConnection({
    required bool resetLocalDatabaseOnOpen,
  }) {
    return driftDatabase(
      name: databaseName,
      native: DriftNativeOptions(
        databasePath: () => prepareLocalDatabasePath(
          name: databaseName,
          reset: resetLocalDatabaseOnOpen,
        ),
      ),
    );
  }
}
