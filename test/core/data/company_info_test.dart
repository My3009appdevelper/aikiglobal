import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/company_info_dao.dart';
import 'package:aikiglobal/core/data/providers/company_info_controller.dart';
import 'package:aikiglobal/core/data/remote/services/company_info_storage_service.dart';
import 'package:aikiglobal/core/data/sync/company_info_sync_service.dart';
import 'package:aikiglobal/core/data/sync/sync_mappers.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('company info storage uses stable image slots', () {
    expect(companyInfoHeroImageSlot, 'hero');
    expect(companyInfoFounderImageSlot(1), 'fundadores/1');
    expect(companyInfoFounderImageSlot(5), 'fundadores/5');
    expect(() => companyInfoFounderImageSlot(0), throwsRangeError);
    expect(() => companyInfoFounderImageSlot(6), throwsRangeError);
  });

  test('companyInfoToRemote maps editable company info columns', () {
    final info = LocalCompanyInfo(
      uuidCompanyInfo: 'company-1',
      slug: CompanyInfoDao.mainSlug,
      heroTitulo: 'Bienvenido a tu espacio de paz interior',
      heroSubtitulo: 'Explora, aprende y conecta contigo.',
      heroImagePath: 'hero/cover.jpg',
      textoEntrada:
          'Bienvenidos a Aiki Wellness Center®, un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.',
      quienesSomos: 'Somos Aiki',
      significadoAiki:
          'Aiki representa armonía, energía y presencia consciente.',
      mision: 'Acompañar procesos de bienestar.',
      vision: 'Crear una comunidad consciente.',
      filosofia: 'Pausar, respirar y volver al presente.',
      mensajeFundadoresTitulo: 'Mensaje de fundadores',
      mensajeFundadoresTexto: 'Una carta amplia para la comunidad Aiki.',
      mensajeFundadoresImagePath1: 'fundadores/1.jpg',
      mensajeFundadoresImagePath2: 'fundadores/2.jpg',
      mensajeFundadoresImagePath3: null,
      mensajeFundadoresImagePath4: '',
      mensajeFundadoresImagePath5: 'fundadores/5.jpg',
      createdAt: DateTime.utc(2026, 7, 15, 18),
      updatedAt: DateTime.utc(2026, 7, 15, 18, 10),
      syncedAt: DateTime.utc(2026, 7, 15, 18, 10),
    );

    final remote = companyInfoToRemote(info);

    expect(remote['uuid_company_info'], 'company-1');
    expect(remote['slug'], CompanyInfoDao.mainSlug);
    expect(remote['hero_titulo'], 'Bienvenido a tu espacio de paz interior');
    expect(remote['hero_subtitulo'], 'Explora, aprende y conecta contigo.');
    expect(remote['hero_image_path'], 'hero/cover.jpg');
    expect(
      remote['texto_entrada'],
      'Bienvenidos a Aiki Wellness Center®, un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.',
    );
    expect(remote['quienes_somos'], 'Somos Aiki');
    expect(
      remote['significado_aiki'],
      'Aiki representa armonía, energía y presencia consciente.',
    );
    expect(remote['mision'], 'Acompañar procesos de bienestar.');
    expect(remote['vision'], 'Crear una comunidad consciente.');
    expect(remote['filosofia'], 'Pausar, respirar y volver al presente.');
    expect(remote['mensaje_fundadores_titulo'], 'Mensaje de fundadores');
    expect(
      remote['mensaje_fundadores_texto'],
      'Una carta amplia para la comunidad Aiki.',
    );
    expect(remote['mensaje_fundadores_image_path1'], 'fundadores/1.jpg');
    expect(remote['mensaje_fundadores_image_path2'], 'fundadores/2.jpg');
    expect(remote['mensaje_fundadores_image_path3'], isNull);
    expect(remote['mensaje_fundadores_image_path4'], '');
    expect(remote['mensaje_fundadores_image_path5'], 'fundadores/5.jpg');
  });

  test('companyInfoRemoteToApp maps Supabase company_info columns', () {
    final info = companyInfoRemoteToApp({
      'uuid_company_info': 'company-1',
      'slug': 'main',
      'hero_titulo': 'Bienvenido a tu espacio de paz interior',
      'hero_subtitulo': 'Explora, aprende y conecta contigo.',
      'hero_image_path': 'hero/cover.jpg',
      'texto_entrada':
          'Bienvenidos a Aiki Wellness Center®, un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.',
      'quienes_somos': 'Somos Aiki',
      'significado_aiki':
          'Aiki representa armonía, energía y presencia consciente.',
      'mision': 'Acompañar procesos de bienestar.',
      'vision': 'Crear una comunidad consciente.',
      'filosofia': 'Pausar, respirar y volver al presente.',
      'mensaje_fundadores_titulo': 'Mensaje de fundadores',
      'mensaje_fundadores_texto': 'Una carta amplia para la comunidad Aiki.',
      'mensaje_fundadores_image_path1': 'fundadores/1.jpg',
      'mensaje_fundadores_image_path2': 'fundadores/2.jpg',
      'mensaje_fundadores_image_path3': null,
      'mensaje_fundadores_image_path4': '',
      'mensaje_fundadores_image_path5': 'fundadores/5.jpg',
      'created_at': '2026-07-15T18:00:00Z',
      'updated_at': '2026-07-15T18:10:00Z',
      'deleted_at': null,
      'synced_at': null,
    });

    expect(info.uuidCompanyInfo, 'company-1');
    expect(info.slug, 'main');
    expect(info.heroTitulo, 'Bienvenido a tu espacio de paz interior');
    expect(info.heroSubtitulo, 'Explora, aprende y conecta contigo.');
    expect(info.heroImagePath, 'hero/cover.jpg');
    expect(
      info.textoEntrada,
      'Bienvenidos a Aiki Wellness Center®, un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.',
    );
    expect(info.quienesSomos, 'Somos Aiki');
    expect(
      info.significadoAiki,
      'Aiki representa armonía, energía y presencia consciente.',
    );
    expect(info.mision, 'Acompañar procesos de bienestar.');
    expect(info.vision, 'Crear una comunidad consciente.');
    expect(info.filosofia, 'Pausar, respirar y volver al presente.');
    expect(info.mensajeFundadoresTitulo, 'Mensaje de fundadores');
    expect(
      info.mensajeFundadoresTexto,
      'Una carta amplia para la comunidad Aiki.',
    );
    expect(info.mensajeFundadoresImagePaths, [
      'fundadores/1.jpg',
      'fundadores/2.jpg',
      'fundadores/5.jpg',
    ]);
    expect(info.hasPendingSync, isFalse);
  });

  test('companyInfoRemoteToCompanion stores pulled company info locally', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final dao = CompanyInfoDao(database);

    await dao.upsertCompanyInfo(
      companyInfoRemoteToCompanion({
        'uuid_company_info': 'company-1',
        'slug': CompanyInfoDao.mainSlug,
        'hero_titulo': 'Bienvenido a tu espacio de paz interior',
        'hero_subtitulo': 'Explora, aprende y conecta contigo.',
        'hero_image_path': 'hero/cover.jpg',
        'texto_entrada':
            'Bienvenidos a Aiki Wellness Center®, un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.',
        'quienes_somos': 'Somos Aiki',
        'significado_aiki':
            'Aiki representa armonía, energía y presencia consciente.',
        'mision': 'Acompañar procesos de bienestar.',
        'vision': 'Crear una comunidad consciente.',
        'filosofia': 'Pausar, respirar y volver al presente.',
        'mensaje_fundadores_titulo': 'Mensaje de fundadores',
        'mensaje_fundadores_texto': 'Una carta amplia para la comunidad Aiki.',
        'mensaje_fundadores_image_path1': 'fundadores/1.jpg',
        'mensaje_fundadores_image_path2': 'fundadores/2.jpg',
        'mensaje_fundadores_image_path3': null,
        'mensaje_fundadores_image_path4': '',
        'mensaje_fundadores_image_path5': 'fundadores/5.jpg',
        'created_at': '2026-07-15T18:00:00Z',
        'updated_at': '2026-07-15T18:10:00Z',
        'deleted_at': null,
      }),
    );

    final localInfo = await dao.getMain();

    expect(localInfo, isNotNull);
    expect(localInfo!.uuidCompanyInfo, 'company-1');
    expect(localInfo.slug, CompanyInfoDao.mainSlug);
    expect(localInfo.heroTitulo, 'Bienvenido a tu espacio de paz interior');
    expect(localInfo.heroSubtitulo, 'Explora, aprende y conecta contigo.');
    expect(localInfo.heroImagePath, 'hero/cover.jpg');
    expect(
      localInfo.textoEntrada,
      'Bienvenidos a Aiki Wellness Center®, un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.',
    );
    expect(localInfo.quienesSomos, 'Somos Aiki');
    expect(
      localInfo.significadoAiki,
      'Aiki representa armonía, energía y presencia consciente.',
    );
    expect(localInfo.mision, 'Acompañar procesos de bienestar.');
    expect(localInfo.vision, 'Crear una comunidad consciente.');
    expect(localInfo.filosofia, 'Pausar, respirar y volver al presente.');
    expect(localInfo.mensajeFundadoresTitulo, 'Mensaje de fundadores');
    expect(
      localInfo.mensajeFundadoresTexto,
      'Una carta amplia para la comunidad Aiki.',
    );
    expect(localInfo.mensajeFundadoresImagePath1, 'fundadores/1.jpg');
    expect(localInfo.mensajeFundadoresImagePath2, 'fundadores/2.jpg');
    expect(localInfo.mensajeFundadoresImagePath3, isNull);
    expect(localInfo.mensajeFundadoresImagePath4, isNull);
    expect(localInfo.mensajeFundadoresImagePath5, 'fundadores/5.jpg');
    expect(localInfo.syncedAt, isNotNull);
  });

  test('CompanyInfoController saves editable company info locally', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final dao = CompanyInfoDao(database);
    final controller = CompanyInfoController(
      companyInfoDao: dao,
      companyInfoRemoteService: null,
      syncService: null,
    );
    addTearDown(controller.dispose);

    await controller.saveInfo(
      heroTitulo: 'Bienvenido a tu espacio de paz interior',
      heroSubtitulo: 'Explora, aprende y conecta contigo.',
      heroImagePath: 'hero/cover.jpg',
      textoEntrada:
          'Bienvenidos a Aiki Wellness Center®, un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.',
      quienesSomos: 'Somos Aiki',
      significadoAiki:
          'Aiki representa armonía, energía y presencia consciente.',
      mision: 'Acompañar procesos de bienestar.',
      vision: 'Crear una comunidad consciente.',
      filosofia: 'Pausar, respirar y volver al presente.',
      mensajeFundadoresTitulo: 'Mensaje de fundadores',
      mensajeFundadoresTexto: 'Una carta amplia para la comunidad Aiki.',
      mensajeFundadoresImagePath1: 'fundadores/1.jpg',
      mensajeFundadoresImagePath2: 'fundadores/2.jpg',
      mensajeFundadoresImagePath3: null,
      mensajeFundadoresImagePath4: '',
      mensajeFundadoresImagePath5: 'fundadores/5.jpg',
    );

    final localInfo = await dao.getMain();

    expect(localInfo, isNotNull);
    expect(localInfo!.slug, CompanyInfoDao.mainSlug);
    expect(localInfo.heroTitulo, 'Bienvenido a tu espacio de paz interior');
    expect(localInfo.heroSubtitulo, 'Explora, aprende y conecta contigo.');
    expect(localInfo.heroImagePath, 'hero/cover.jpg');
    expect(
      localInfo.textoEntrada,
      'Bienvenidos a Aiki Wellness Center®, un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.',
    );
    expect(localInfo.quienesSomos, 'Somos Aiki');
    expect(
      localInfo.significadoAiki,
      'Aiki representa armonía, energía y presencia consciente.',
    );
    expect(localInfo.mensajeFundadoresTitulo, 'Mensaje de fundadores');
    expect(
      localInfo.mensajeFundadoresTexto,
      'Una carta amplia para la comunidad Aiki.',
    );
    expect(localInfo.mensajeFundadoresImagePath1, 'fundadores/1.jpg');
    expect(localInfo.mensajeFundadoresImagePath2, 'fundadores/2.jpg');
    expect(localInfo.mensajeFundadoresImagePath3, isNull);
    expect(localInfo.mensajeFundadoresImagePath4, isNull);
    expect(localInfo.mensajeFundadoresImagePath5, 'fundadores/5.jpg');
    expect(localInfo.syncedAt, isNull);
    expect(controller.item.hasPendingSync, isTrue);
  });

  test(
    'CompanyInfoController surfaces remote sync failures after saving',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);
      final dao = CompanyInfoDao(database);
      final syncError = StateError('remote sync failed');
      final controller = CompanyInfoController(
        companyInfoDao: dao,
        companyInfoRemoteService: null,
        syncService: _ThrowingCompanyInfoSyncService(syncError),
      );
      addTearDown(controller.dispose);

      await expectLater(
        controller.saveInfo(
          heroTitulo: 'Bienvenido a tu espacio de paz interior',
          heroSubtitulo: 'Explora, aprende y conecta contigo.',
          heroImagePath: 'hero/cover.jpg',
          textoEntrada:
              'Bienvenidos a Aiki Wellness Center®, un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.',
          quienesSomos: 'Somos Aiki',
          significadoAiki:
              'Aiki representa armonía, energía y presencia consciente.',
          mision: 'Acompañar procesos de bienestar.',
          vision: 'Crear una comunidad consciente.',
          filosofia: 'Pausar, respirar y volver al presente.',
          mensajeFundadoresTitulo: 'Mensaje de fundadores',
          mensajeFundadoresTexto: 'Una carta amplia para la comunidad Aiki.',
          mensajeFundadoresImagePath1: null,
          mensajeFundadoresImagePath2: null,
          mensajeFundadoresImagePath3: null,
          mensajeFundadoresImagePath4: null,
          mensajeFundadoresImagePath5: null,
          syncAfterSave: true,
        ),
        throwsA(same(syncError)),
      );

      final localInfo = await dao.getMain();

      expect(localInfo, isNotNull);
      expect(localInfo!.syncedAt, isNull);
      expect(controller.error, same(syncError));
    },
  );
}

class _ThrowingCompanyInfoSyncService implements CompanyInfoSyncService {
  const _ThrowingCompanyInfoSyncService(this.error);

  final Object error;

  @override
  Future<void> sync() async {
    throw error;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
