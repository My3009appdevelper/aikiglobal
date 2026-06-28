import 'package:aikiglobal/core/data/models/content_media_file_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('infers media type and title from selected file name', () {
    final metadata = ContentMediaFileMetadata.fromFileName('Respiración.mp4');

    expect(metadata.tipo, 'mp4');
    expect(metadata.titulo, 'Respiración');
    expect(metadata.contentType, 'video/mp4');
  });

  test('normalizes upper-case extensions', () {
    final metadata = ContentMediaFileMetadata.fromFileName('Nota de voz.MP3');

    expect(metadata.tipo, 'mp3');
    expect(metadata.titulo, 'Nota de voz');
    expect(metadata.contentType, 'audio/mpeg');
  });
}
