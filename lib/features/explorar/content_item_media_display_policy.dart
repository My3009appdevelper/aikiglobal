import 'models/content_item.dart';

bool contentItemShowsMediaStages(ContentItem item) {
  if (item.lessons != null) {
    return true;
  }

  return switch (_normalizedContentType(item.type)) {
    'course' || 'curso' => true,
    _ => false,
  };
}

String _normalizedContentType(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');
}
