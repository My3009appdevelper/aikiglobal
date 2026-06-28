import 'package:aikiglobal/features/admin/admin_content/content_media_metadata_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('courses keep media title and duration editable', () {
    expect(contentMediaMetadataIsEditable('course'), isTrue);

    final metadata = contentMediaMetadataForSave(
      contentType: 'course',
      contentTitle: 'Curso base',
      contentDurationSeconds: 600,
      mediaTitle: 'Clase 1',
      mediaDurationSeconds: 120,
    );

    expect(metadata.title, 'Clase 1');
    expect(metadata.durationSeconds, 120);
  });

  test('non-course content uses item title and duration for media', () {
    expect(contentMediaMetadataIsEditable('meditation'), isFalse);
    expect(contentMediaMetadataIsEditable('audio'), isFalse);
    expect(contentMediaMetadataIsEditable('sound'), isFalse);

    final metadata = contentMediaMetadataForSave(
      contentType: 'meditation',
      contentTitle: 'Respirar con calma',
      contentDurationSeconds: 900,
      mediaTitle: 'archivo-importado',
      mediaDurationSeconds: 42,
    );

    expect(metadata.title, 'Respirar con calma');
    expect(metadata.durationSeconds, 900);
  });
}
