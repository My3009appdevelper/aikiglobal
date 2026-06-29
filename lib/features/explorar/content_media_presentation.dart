import '../../core/data/models/app_content_media.dart';
import '../../core/data/models/content_media_file_metadata.dart';
import 'models/content_item.dart';

bool contentItemSupportsAudioDarkScreen(
  ContentItem item, {
  required AppContentMedia? selectedMedia,
}) {
  if (selectedMedia == null) {
    return false;
  }

  if (ContentMediaFileMetadata.isVideoType(selectedMedia.tipo)) {
    return false;
  }

  return _isAudioOrSoundContentType(item.type);
}

String contentMediaKindLabel(String tipo, {String? contentItemType}) {
  final cleanType = tipo.trim().toLowerCase();
  final cleanContentType = contentItemType?.trim().toLowerCase();

  if (ContentMediaFileMetadata.isVideoType(cleanType) || cleanType == 'video') {
    return 'Video';
  }

  if (_isSoundContentType(cleanContentType)) {
    return 'Sonido ambiental';
  }

  if (ContentMediaFileMetadata.isSupportedType(cleanType) ||
      cleanType == 'audio') {
    return 'Audio';
  }

  return switch (cleanType) {
    'ambient_sound' || 'sound' || 'sonido' => 'Sonido ambiental',
    _ => tipo,
  };
}

String contentMediaSubtitle(AppContentMedia item) {
  return contentMediaDurationLabel(item.duracionSegundos);
}

String contentMediaDurationLabel(int? seconds) {
  if (seconds == null || seconds <= 0) {
    return 'Duración pendiente';
  }

  final totalMinutes = (seconds / 60).round();
  if (totalMinutes < 60) {
    return '$totalMinutes min';
  }

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
}

bool _isAudioOrSoundContentType(String value) {
  final cleanValue = value.trim().toLowerCase();
  return cleanValue == 'audio' || _isSoundContentType(cleanValue);
}

bool _isSoundContentType(String? value) {
  final cleanValue = value?.trim().toLowerCase();
  return cleanValue == 'sound' ||
      cleanValue == 'sonido' ||
      cleanValue == 'sonidos' ||
      cleanValue == 'ambient_sound' ||
      cleanValue == 'sonido ambiental';
}
