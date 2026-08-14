import 'package:drift/drift.dart';

@DataClassName('LocalCompanyInfo')
class CompanyInfoTable extends Table {
  @override
  String get tableName => 'local_company_info';

  TextColumn get uuidCompanyInfo => text().named('uuid_company_info')();
  TextColumn get slug => text().withDefault(const Constant('main')).unique()();
  TextColumn get heroTitulo =>
      text().named('hero_titulo').withDefault(const Constant(''))();
  TextColumn get heroSubtitulo =>
      text().named('hero_subtitulo').withDefault(const Constant(''))();
  TextColumn get heroImagePath => text().named('hero_image_path').nullable()();
  TextColumn get textoEntrada =>
      text().named('texto_entrada').withDefault(const Constant(''))();
  TextColumn get quienesSomos => text().named('quienes_somos')();
  TextColumn get significadoAiki =>
      text().named('significado_aiki').withDefault(const Constant(''))();
  TextColumn get mision => text()();
  TextColumn get vision => text()();
  TextColumn get filosofia => text()();
  TextColumn get mensajeFundadoresTitulo => text()
      .named('mensaje_fundadores_titulo')
      .withDefault(const Constant(''))();
  TextColumn get mensajeFundadoresTexto => text()
      .named('mensaje_fundadores_texto')
      .withDefault(const Constant(''))();
  TextColumn get mensajeFundadoresImagePath1 =>
      text().named('mensaje_fundadores_image_path1').nullable()();
  TextColumn get mensajeFundadoresImagePath2 =>
      text().named('mensaje_fundadores_image_path2').nullable()();
  TextColumn get mensajeFundadoresImagePath3 =>
      text().named('mensaje_fundadores_image_path3').nullable()();
  TextColumn get mensajeFundadoresImagePath4 =>
      text().named('mensaje_fundadores_image_path4').nullable()();
  TextColumn get mensajeFundadoresImagePath5 =>
      text().named('mensaje_fundadores_image_path5').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuidCompanyInfo};
}
