import '../../core/data/models/app_content_media.dart';

AppContentMedia? selectPlayableContentMedia(
  Iterable<AppContentMedia> items, {
  String? selectedMediaUuid,
}) {
  final playable = playableContentMediaItems(items);

  if (playable.isEmpty) {
    return null;
  }

  final cleanSelectedUuid = selectedMediaUuid?.trim();
  if (cleanSelectedUuid != null && cleanSelectedUuid.isNotEmpty) {
    for (final item in playable) {
      if (item.uuidContentMedia == cleanSelectedUuid) {
        return item;
      }
    }
  }

  return playable.first;
}

List<AppContentMedia> playableContentMediaItems(
  Iterable<AppContentMedia> items,
) {
  return items.where((item) => item.isPublishable).toList()..sort((a, b) {
    final orderCompare = a.orden.compareTo(b.orden);
    if (orderCompare != 0) {
      return orderCompare;
    }
    return a.createdAt.compareTo(b.createdAt);
  });
}
