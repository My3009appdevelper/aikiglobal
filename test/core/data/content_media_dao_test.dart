import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/content_media_dao.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'getPublishableCountByContent ignores deleted media and empty storage',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      final dao = ContentMediaDao(database);

      await dao.upsertContentMedia(
        ContentMediaTableCompanion.insert(
          uuidContentMedia: 'media-active',
          uuidContentItem: 'content-1',
          tipo: 'mp3',
          titulo: const Value('Audio principal'),
          storagePathSupabase: 'content-1/media/media-active/file.mp3',
        ),
      );
      await dao.upsertContentMedia(
        ContentMediaTableCompanion.insert(
          uuidContentMedia: 'media-empty-storage',
          uuidContentItem: 'content-1',
          tipo: 'mp4',
          titulo: const Value('Video sin storage'),
          storagePathSupabase: '',
        ),
      );
      await dao.upsertContentMedia(
        ContentMediaTableCompanion.insert(
          uuidContentMedia: 'media-deleted',
          uuidContentItem: 'content-1',
          tipo: 'wav',
          titulo: const Value('Sonido eliminado'),
          storagePathSupabase: 'content-1/media/media-deleted/file.wav',
          deletedAt: Value(DateTime.utc(2026, 6, 28)),
        ),
      );

      expect(await dao.getPublishableCountByContent('content-1'), 1);
      await database.close();
    },
  );
}
