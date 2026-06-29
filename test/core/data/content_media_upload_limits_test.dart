import 'package:aikiglobal/core/data/models/content_media_upload_limits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allows videos up to 500 MB and audio up to 200 MB', () {
    expect(
      validateContentMediaFileSize(tipo: 'mp4', sizeBytes: 500 * 1024 * 1024),
      isNull,
    );
    expect(
      validateContentMediaFileSize(tipo: 'mp3', sizeBytes: 200 * 1024 * 1024),
      isNull,
    );
  });

  test('returns a user-facing message when the selected file is too large', () {
    expect(
      validateContentMediaFileSize(tipo: 'mp4', sizeBytes: 501 * 1024 * 1024),
      'El video seleccionado supera el límite de 500 MB.',
    );
    expect(
      validateContentMediaFileSize(tipo: 'm4a', sizeBytes: 201 * 1024 * 1024),
      'El audio seleccionado supera el límite de 200 MB.',
    );
  });
}
