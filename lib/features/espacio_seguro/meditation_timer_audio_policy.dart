import '../../core/data/models/app_content_item.dart';
import '../../core/data/models/app_content_media.dart';

List<AppContentItem> publishedMeditationTimerSounds(
  Iterable<AppContentItem> items,
) {
  return items.where((item) {
    return item.isPublished && isMeditationTimerSoundType(item.tipo);
  }).toList();
}

bool isMeditationTimerSoundType(String value) {
  final cleanValue = value.trim().toLowerCase();
  return cleanValue == 'sound' ||
      cleanValue == 'sonido' ||
      cleanValue == 'sonidos' ||
      cleanValue == 'ambient_sound' ||
      cleanValue == 'sonido ambiental';
}

AppContentMedia? selectMeditationTimerSoundMedia(
  Iterable<AppContentMedia> items, {
  required String uuidContentItem,
}) {
  final cleanContentUuid = uuidContentItem.trim();
  if (cleanContentUuid.isEmpty) {
    return null;
  }

  final playable =
      items.where((item) {
        return item.uuidContentItem == cleanContentUuid && item.isPublishable;
      }).toList()..sort((a, b) {
        final orderCompare = a.orden.compareTo(b.orden);
        if (orderCompare != 0) {
          return orderCompare;
        }
        return a.createdAt.compareTo(b.createdAt);
      });

  return playable.isEmpty ? null : playable.first;
}
