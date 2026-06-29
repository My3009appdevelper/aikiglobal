import 'package:aikiglobal/features/explorar/content_item_media_display_policy.dart';
import 'package:aikiglobal/features/explorar/models/content_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shows staged media list only for courses', () {
    expect(contentItemShowsMediaStages(_item(type: 'Curso')), isTrue);
    expect(contentItemShowsMediaStages(_item(type: 'course')), isTrue);
    expect(
      contentItemShowsMediaStages(_item(type: 'Programa', lessons: 4)),
      isTrue,
    );

    expect(contentItemShowsMediaStages(_item(type: 'Meditación')), isFalse);
    expect(contentItemShowsMediaStages(_item(type: 'Audio')), isFalse);
    expect(contentItemShowsMediaStages(_item(type: 'Sonido')), isFalse);
  });
}

ContentItem _item({required String type, int? lessons}) {
  return ContentItem(
    title: 'Contenido',
    type: type,
    duration: '10 min',
    imageAsset: 'asset.png',
    lessons: lessons,
  );
}
