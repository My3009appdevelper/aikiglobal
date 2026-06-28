import 'package:aikiglobal/core/data/models/app_content_media.dart';
import 'package:aikiglobal/core/data/models/pending_content_media_upload.dart';
import 'package:aikiglobal/features/admin/admin_content/content_media_form_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hides persisted media marked for removal', () {
    final draft = ContentMediaFormDraft(
      persistedMedia: [_media('media-1'), _media('media-2')],
      pendingUploads: const [],
      removedMediaIds: const {'media-1'},
    );

    expect(draft.visiblePersistedMedia.map((media) => media.uuidContentMedia), [
      'media-2',
    ]);
    expect(draft.hasMediaChanges, isTrue);
    expect(draft.hasPublishableMediaAfterChanges, isTrue);
  });

  test('blocks publish when the only media is marked for removal', () {
    final draft = ContentMediaFormDraft(
      persistedMedia: [_media('media-1')],
      pendingUploads: const [],
      removedMediaIds: const {'media-1'},
    );

    expect(draft.visiblePersistedMedia, isEmpty);
    expect(draft.hasPublishableMediaAfterChanges, isFalse);
  });

  test('counts pending replacement after removing persisted media', () {
    final draft = ContentMediaFormDraft(
      persistedMedia: [_media('media-1')],
      pendingUploads: [_pendingUpload('media-2')],
      removedMediaIds: const {'media-1'},
    );

    expect(draft.hasPublishableMediaAfterChanges, isTrue);
  });

  test(
    'hides pending upload once the persisted row with same uuid appears',
    () {
      final draft = ContentMediaFormDraft(
        persistedMedia: [_media('media-1')],
        pendingUploads: [_pendingUpload('media-1'), _pendingUpload('media-2')],
        removedMediaIds: const {},
      );

      expect(
        draft.visiblePendingUploads.map((media) => media.uuidContentMedia),
        ['media-2'],
      );
    },
  );

  test('uses the next sort order after visible media', () {
    final draft = ContentMediaFormDraft(
      persistedMedia: [
        _media('media-1', orden: 0),
        _media('media-2', orden: 3),
      ],
      pendingUploads: [_pendingUpload('media-3', orden: 4)],
      removedMediaIds: const {'media-1'},
    );

    expect(draft.nextSortOrder, 5);
  });

  test('metadata edit detects changes from persisted media', () {
    final media = _media('media-1', titulo: 'Clase', duracionSegundos: 90);

    final unchanged = ContentMediaMetadataEdit.fromMedia(media);
    final changed = unchanged.copyWith(
      titulo: 'Clase editada',
      duracionSegundos: 120,
    );

    expect(unchanged.hasChangesFrom(media), isFalse);
    expect(changed.hasChangesFrom(media), isTrue);
  });

  test('metadata edit can clear persisted duration', () {
    final media = _media('media-1', titulo: 'Clase', duracionSegundos: 90);

    final changed = ContentMediaMetadataEdit.fromMedia(
      media,
    ).copyWith(duracionSegundos: null);

    expect(changed.duracionSegundos, isNull);
    expect(changed.hasChangesFrom(media), isTrue);
  });
}

AppContentMedia _media(
  String uuidContentMedia, {
  int orden = 0,
  String? titulo = 'Clase',
  int? duracionSegundos,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return AppContentMedia(
    uuidContentMedia: uuidContentMedia,
    uuidContentItem: 'content-1',
    tipo: 'mp4',
    titulo: titulo,
    storagePathSupabase: 'content/content-1/$uuidContentMedia.mp4',
    duracionSegundos: duracionSegundos,
    orden: orden,
    createdAt: now,
    updatedAt: now,
  );
}

PendingContentMediaUpload _pendingUpload(
  String uuidContentMedia, {
  int orden = 0,
}) {
  return PendingContentMediaUpload(
    uuidContentMedia: uuidContentMedia,
    tipo: 'mp4',
    titulo: 'Clase',
    fileName: 'Clase.mp4',
    contentType: 'video/mp4',
    orden: orden,
  );
}
