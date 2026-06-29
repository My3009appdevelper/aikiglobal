import 'package:aikiglobal/core/data/models/app_content_item.dart';
import 'package:aikiglobal/core/data/models/app_content_media.dart';
import 'package:aikiglobal/features/espacio_seguro/meditation_timer_audio_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps only published sound content types for the timer', () {
    final sounds = publishedMeditationTimerSounds([
      _item(uuid: 'sound', tipo: 'sound'),
      _item(uuid: 'ambient', tipo: 'ambient_sound'),
      _item(uuid: 'spanish', tipo: 'sonido'),
      _item(uuid: 'audio', tipo: 'audio'),
      _item(uuid: 'draft', tipo: 'sound', status: 'draft'),
    ]);

    expect(sounds.map((item) => item.uuidContentItem), [
      'sound',
      'ambient',
      'spanish',
    ]);
  });

  test('selects the first publishable media for a selected timer sound', () {
    final selected = selectMeditationTimerSoundMedia([
      _media(
        uuid: 'video',
        contentUuid: 'sound-1',
        tipo: 'mp4',
        storagePath: 'content_media/sound-1/video.mp4',
        order: 0,
      ),
      _media(
        uuid: 'mime-audio',
        contentUuid: 'sound-1',
        tipo: 'audio/mpeg',
        storagePath: 'content_media/sound-1/ambiente',
        order: 2,
      ),
      _media(
        uuid: 'path-audio',
        contentUuid: 'sound-1',
        tipo: 'audio',
        storagePath: 'content_media/sound-1/ambiente.mp3',
        order: 1,
      ),
      _media(
        uuid: 'other-content',
        contentUuid: 'other',
        tipo: 'mp3',
        storagePath: 'content_media/other/ambiente.mp3',
        order: 0,
      ),
    ], uuidContentItem: 'sound-1');

    expect(selected?.uuidContentMedia, 'video');
  });
}

AppContentItem _item({
  required String uuid,
  required String tipo,
  String status = 'published',
}) {
  final now = DateTime.utc(2026);
  return AppContentItem(
    uuidContentItem: uuid,
    tipo: tipo,
    titulo: uuid,
    status: status,
    destacado: false,
    descargable: false,
    orden: 0,
    createdAt: now,
    updatedAt: now,
  );
}

AppContentMedia _media({
  required String uuid,
  required String contentUuid,
  required String tipo,
  required String storagePath,
  required int order,
}) {
  final now = DateTime.utc(2026);
  return AppContentMedia(
    uuidContentMedia: uuid,
    uuidContentItem: contentUuid,
    tipo: tipo,
    titulo: uuid,
    storagePathSupabase: storagePath,
    orden: order,
    createdAt: now.add(Duration(minutes: order)),
    updatedAt: now,
  );
}
