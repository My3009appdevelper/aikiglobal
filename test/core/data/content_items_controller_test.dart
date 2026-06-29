import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/content_items_dao.dart';
import 'package:aikiglobal/core/data/providers/content_items_controller.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'loads a published snapshot without replacing controller items',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);
      final dao = ContentItemsDao(database);
      final now = DateTime.utc(2026);

      await dao.upsertContentItems([
        _item(uuid: 'audio-1', tipo: 'audio', titulo: 'Audio', now: now),
        _item(uuid: 'sound-1', tipo: 'sound', titulo: 'Sonido', now: now),
      ]);

      final controller = ContentItemsController(
        contentItemsDao: dao,
        contentItemsRemoteService: null,
        contentMediaStorageService: null,
        syncService: null,
      );

      await controller.searchPublished('Audio');
      expect(controller.items.map((item) => item.uuidContentItem), ['audio-1']);

      final snapshot = await controller.getPublishedSnapshot();

      expect(snapshot.map((item) => item.uuidContentItem), [
        'audio-1',
        'sound-1',
      ]);
      expect(controller.items.map((item) => item.uuidContentItem), ['audio-1']);
    },
  );
}

ContentItemsTableCompanion _item({
  required String uuid,
  required String tipo,
  required String titulo,
  required DateTime now,
}) {
  return ContentItemsTableCompanion.insert(
    uuidContentItem: uuid,
    tipo: tipo,
    titulo: titulo,
    status: const Value('published'),
    destacado: const Value(false),
    descargable: const Value(false),
    orden: const Value(0),
    createdAt: Value(now),
    updatedAt: Value(now),
    syncedAt: Value(now),
  );
}
