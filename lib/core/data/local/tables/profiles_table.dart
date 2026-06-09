import 'package:drift/drift.dart';

const profileRoles = ['admin', 'user'];

@DataClassName('LocalProfile')
class ProfilesTable extends Table {
  @override
  String get tableName => 'local_profiles';

  TextColumn get uuidProfile => text().named('uuid_profile')();
  TextColumn get authUserId => text().named('auth_user_id').unique()();
  TextColumn get nombre => text().nullable()();
  TextColumn get email => text()();
  TextColumn get fotoPathSupabase =>
      text().named('foto_path_supabase').nullable()();
  TextColumn get fotoPathLocal => text().named('foto_path_local').nullable()();
  TextColumn get role => text()
      // ignore: recursive_getters
      .check(role.isIn(profileRoles))
      .withDefault(const Constant('user'))();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  BoolColumn get onboardingCompletado => boolean()
      .named('onboarding_completado')
      .withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuidProfile};
}
