import 'dart:io';
import 'dart:typed_data';

import 'package:aikiglobal/core/data/models/pending_content_media_upload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('readBytes returns deferred in-memory bytes', () async {
    final upload = PendingContentMediaUpload(
      uuidContentMedia: 'media-1',
      tipo: 'mp3',
      titulo: 'Nota de voz',
      fileName: 'Nota de voz.mp3',
      contentType: 'audio/mpeg',
      orden: 0,
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    expect(await upload.readBytes(), [1, 2, 3]);
  });

  test('readBytes reads local path only when needed', () async {
    final file = File(
      '${Directory.systemTemp.path}/pending_content_media_upload_test.bin',
    );
    await file.writeAsBytes([4, 5, 6]);
    addTearDown(() async {
      if (await file.exists()) {
        await file.delete();
      }
    });

    final upload = PendingContentMediaUpload(
      uuidContentMedia: 'media-1',
      tipo: 'mp4',
      titulo: 'Clase',
      fileName: 'Clase.mp4',
      contentType: 'video/mp4',
      orden: 0,
      localPath: file.path,
    );

    expect(await upload.readBytes(), [4, 5, 6]);
  });

  test(
    'uses local file as preferred upload source without in-memory bytes',
    () {
      final upload = PendingContentMediaUpload(
        uuidContentMedia: 'media-1',
        tipo: 'mp4',
        titulo: 'Clase',
        fileName: 'Clase.mp4',
        contentType: 'video/mp4',
        orden: 0,
        localPath: ' C:/media/clase.mp4 ',
        fileSizeBytes: 120,
      );

      expect(upload.cleanLocalPath, 'C:/media/clase.mp4');
      expect(upload.hasLocalFileSource, isTrue);
      expect(upload.hasInMemoryBytes, isFalse);
      expect(upload.hasReadableSource, isTrue);
    },
  );

  test('copyWith updates editable title and duration', () {
    final upload = PendingContentMediaUpload(
      uuidContentMedia: 'media-1',
      tipo: 'mp4',
      titulo: 'Clase',
      fileName: 'Clase.mp4',
      contentType: 'video/mp4',
      orden: 0,
      duracionSegundos: 90,
    );

    final updated = upload.copyWith(
      titulo: 'Clase editada',
      duracionSegundos: 120,
    );

    expect(updated.uuidContentMedia, upload.uuidContentMedia);
    expect(updated.titulo, 'Clase editada');
    expect(updated.duracionSegundos, 120);
  });

  test('copyWith can clear duration', () {
    final upload = PendingContentMediaUpload(
      uuidContentMedia: 'media-1',
      tipo: 'mp4',
      titulo: 'Clase',
      fileName: 'Clase.mp4',
      contentType: 'video/mp4',
      orden: 0,
      duracionSegundos: 90,
    );

    final updated = upload.copyWith(duracionSegundos: null);

    expect(updated.duracionSegundos, isNull);
  });
}
