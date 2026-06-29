import 'package:aikiglobal/core/data/models/app_content_media.dart';
import 'package:aikiglobal/features/explorar/content_media_presentation.dart';
import 'package:aikiglobal/features/explorar/models/content_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('describes audio files without exposing the file extension', () {
    final media = _media(tipo: 'mp3', duracionSegundos: 1800);

    expect(contentMediaKindLabel(media.tipo), 'Audio');
    expect(contentMediaSubtitle(media), '30 min');
    expect(contentMediaSubtitle(media), isNot(contains('MP3')));
  });

  test('uses an ambient label for sound content without exposing mp3', () {
    expect(
      contentMediaKindLabel('mp3', contentItemType: 'sound'),
      'Sonido ambiental',
    );
  });

  test('enables dark screen mode only for audio and sound content', () {
    final audioMedia = _media(tipo: 'mp3');
    final videoMedia = _media(tipo: 'mp4');

    expect(
      contentItemSupportsAudioDarkScreen(
        _item(type: 'audio'),
        selectedMedia: audioMedia,
      ),
      isTrue,
    );
    expect(
      contentItemSupportsAudioDarkScreen(
        _item(type: 'sound'),
        selectedMedia: audioMedia,
      ),
      isTrue,
    );
    expect(
      contentItemSupportsAudioDarkScreen(
        _item(type: 'course'),
        selectedMedia: audioMedia,
      ),
      isFalse,
    );
    expect(
      contentItemSupportsAudioDarkScreen(
        _item(type: 'audio'),
        selectedMedia: videoMedia,
      ),
      isFalse,
    );
  });
}

AppContentMedia _media({required String tipo, int? duracionSegundos}) {
  final now = DateTime.utc(2026);
  return AppContentMedia(
    uuidContentMedia: 'media-$tipo',
    uuidContentItem: 'content-1',
    tipo: tipo,
    titulo: 'Media',
    storagePathSupabase: 'content/media/file',
    duracionSegundos: duracionSegundos,
    orden: 0,
    createdAt: now,
    updatedAt: now,
  );
}

ContentItem _item({required String type}) {
  return ContentItem(
    title: 'Contenido',
    type: type,
    duration: '30 min',
    imageAsset: 'asset.png',
  );
}
