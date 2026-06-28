import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/sync/sync_mappers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contentMediaRemoteToApp maps Supabase content_media columns', () {
    final appMedia = contentMediaRemoteToApp({
      'uuid_content_media': 'media-1',
      'uuid_content_item': 'content-1',
      'type': 'mp3',
      'title': 'Respiración inicial',
      'storage_path': 'content-1/media/media-1/file.mp3',
      'duration_seconds': 180,
      'sort_order': 2,
      'created_at': '2026-06-28T18:00:00Z',
      'updated_at': '2026-06-28T18:10:00Z',
      'deleted_at': null,
      'synced_at': null,
    });

    expect(appMedia.uuidContentMedia, 'media-1');
    expect(appMedia.uuidContentItem, 'content-1');
    expect(appMedia.tipo, 'mp3');
    expect(appMedia.titulo, 'Respiración inicial');
    expect(appMedia.storagePathSupabase, 'content-1/media/media-1/file.mp3');
    expect(appMedia.duracionSegundos, 180);
    expect(appMedia.orden, 2);
    expect(appMedia.isPublishable, isTrue);
  });

  test('contentMediaToRemote uses the Supabase content_media contract', () {
    final remote = contentMediaToRemote(
      LocalContentMedia(
        uuidContentMedia: 'media-1',
        uuidContentItem: 'content-1',
        tipo: 'mp4',
        titulo: 'Clase inicial',
        storagePathSupabase: 'content-1/media/media-1/file.mp4',
        storagePathLocal: 'C:/cache/file.mp4',
        duracionSegundos: 600,
        orden: 1,
        createdAt: DateTime.utc(2026, 6, 28, 18),
        updatedAt: DateTime.utc(2026, 6, 28, 18, 10),
        deletedAt: null,
        syncedAt: null,
      ),
    );

    expect(remote['uuid_content_media'], 'media-1');
    expect(remote['uuid_content_item'], 'content-1');
    expect(remote['type'], 'mp4');
    expect(remote['title'], 'Clase inicial');
    expect(remote['storage_path'], 'content-1/media/media-1/file.mp4');
    expect(remote['storage_path_local'], isNull);
    expect(remote['duration_seconds'], 600);
    expect(remote['sort_order'], 1);
    expect(remote.containsKey('status'), isFalse);
  });

  test('contentMediaRemoteToCompanion stores remote metadata locally', () {
    final companion = contentMediaRemoteToCompanion({
      'uuid_content_media': 'media-1',
      'uuid_content_item': 'content-1',
      'type': 'wav',
      'title': 'Lluvia suave',
      'storage_path': 'content-1/media/media-1/file.wav',
      'duration_seconds': 300,
      'sort_order': 3,
      'created_at': '2026-06-28T18:00:00Z',
      'updated_at': '2026-06-28T18:10:00Z',
      'deleted_at': null,
    });

    expect(companion.uuidContentMedia.value, 'media-1');
    expect(companion.uuidContentItem.value, 'content-1');
    expect(companion.tipo.value, 'wav');
    expect(companion.titulo.value, 'Lluvia suave');
    expect(
      companion.storagePathSupabase.value,
      'content-1/media/media-1/file.wav',
    );
    expect(companion.duracionSegundos.value, 300);
    expect(companion.orden.value, 3);
  });
}
