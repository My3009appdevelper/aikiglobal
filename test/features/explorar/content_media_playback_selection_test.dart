import 'package:aikiglobal/core/data/models/app_content_media.dart';
import 'package:aikiglobal/features/explorar/content_media_playback_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selects the requested publishable media when it exists', () {
    final items = [
      _media(uuid: 'first', order: 0),
      _media(uuid: 'second', order: 1),
    ];

    final selected = selectPlayableContentMedia(
      items,
      selectedMediaUuid: 'second',
    );

    expect(selected?.uuidContentMedia, 'second');
  });

  test('falls back to the first publishable media by sort order', () {
    final items = [
      _media(uuid: 'third', order: 3),
      _media(uuid: 'first', order: 1),
      _media(uuid: 'empty-path', order: 0, storagePath: ''),
      _media(uuid: 'deleted', order: 0, deletedAt: DateTime(2026)),
    ];

    final selected = selectPlayableContentMedia(
      items,
      selectedMediaUuid: 'missing',
    );

    expect(selected?.uuidContentMedia, 'first');
  });
}

AppContentMedia _media({
  required String uuid,
  required int order,
  String storagePath = 'content/media/file.mp4',
  DateTime? deletedAt,
}) {
  final now = DateTime.utc(2026);
  return AppContentMedia(
    uuidContentMedia: uuid,
    uuidContentItem: 'content',
    tipo: 'mp4',
    titulo: uuid,
    storagePathSupabase: storagePath,
    orden: order,
    createdAt: now.add(Duration(minutes: order)),
    updatedAt: now,
    deletedAt: deletedAt,
    syncedAt: now,
  );
}
