import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'app_database_file.dart';
import 'tables/company_info_table.dart';
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
    CompanyInfoTable,
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
  int get schemaVersion => 6;

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
        if (from < 4) {
          await m.createTable(companyInfoTable);
        } else if (from < 5) {
          await m.addColumn(companyInfoTable, companyInfoTable.textoEntrada);
          await m.addColumn(companyInfoTable, companyInfoTable.significadoAiki);
        }
        if (from >= 4 && from < 6) {
          await m.addColumn(companyInfoTable, companyInfoTable.heroTitulo);
          await m.addColumn(companyInfoTable, companyInfoTable.heroSubtitulo);
          await m.addColumn(companyInfoTable, companyInfoTable.heroImagePath);
          await m.addColumn(
            companyInfoTable,
            companyInfoTable.mensajeFundadoresTitulo,
          );
          await m.addColumn(
            companyInfoTable,
            companyInfoTable.mensajeFundadoresTexto,
          );
          await m.addColumn(
            companyInfoTable,
            companyInfoTable.mensajeFundadoresImagePath1,
          );
          await m.addColumn(
            companyInfoTable,
            companyInfoTable.mensajeFundadoresImagePath2,
          );
          await m.addColumn(
            companyInfoTable,
            companyInfoTable.mensajeFundadoresImagePath3,
          );
          await m.addColumn(
            companyInfoTable,
            companyInfoTable.mensajeFundadoresImagePath4,
          );
          await m.addColumn(
            companyInfoTable,
            companyInfoTable.mensajeFundadoresImagePath5,
          );
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
