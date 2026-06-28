import 'package:aikiglobal/core/data/providers/content_media_controller.dart';
import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/content_media_dao.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isValidMediaType accepts only supported media types', () {
    expect(ContentMediaController.isValidMediaType('mp4'), isTrue);
    expect(ContentMediaController.isValidMediaType('MP3'), isTrue);
    expect(ContentMediaController.isValidMediaType('wav'), isTrue);
    expect(ContentMediaController.isValidMediaType('audio'), isFalse);
    expect(ContentMediaController.isValidMediaType('video'), isFalse);
    expect(ContentMediaController.isValidMediaType('pdf'), isFalse);
  });

  test(
    'normalizeMediaType derives extension from file name when type is stale',
    () {
      expect(
        ContentMediaController.normalizeMediaType(
          'audio',
          fileName: 'Nota de voz.mp3',
        ),
        'mp3',
      );
      expect(
        ContentMediaController.normalizeMediaType(
          'video',
          fileName: 'Clase.MP4',
        ),
        'mp4',
      );
    },
  );

  test(
    'updateMediaMetadata updates local metadata and marks pending sync',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);
      final dao = ContentMediaDao(database);
      final now = DateTime.utc(2026, 6, 28);

      await dao.upsertContentMedia(
        ContentMediaTableCompanion.insert(
          uuidContentMedia: 'media-1',
          uuidContentItem: 'content-1',
          tipo: 'mp4',
          titulo: const Value('Clase'),
          storagePathSupabase: 'content-1/media/media-1/file.mp4',
          duracionSegundos: const Value(90),
          orden: const Value(0),
          createdAt: Value(now),
          updatedAt: Value(now),
          syncedAt: Value(now),
        ),
      );

      final controller = ContentMediaController(
        contentMediaDao: dao,
        contentMediaRemoteService: null,
        contentMediaStorageService: null,
        syncService: null,
      );

      await controller.updateMediaMetadata(
        uuidContentMedia: 'media-1',
        tipo: 'mp4',
        titulo: 'Clase editada',
        duracionSegundos: 120,
        orden: 2,
      );

      final updated = await dao.getByUuid('media-1');
      expect(updated?.titulo, 'Clase editada');
      expect(updated?.duracionSegundos, 120);
      expect(updated?.orden, 2);
      expect(updated?.syncedAt, null);
    },
  );
}
