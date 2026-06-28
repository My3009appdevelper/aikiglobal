import '../../../core/data/models/app_content_media.dart';
import '../../../core/data/models/pending_content_media_upload.dart';

const _unset = Object();

class ContentMediaFormDraft {
  ContentMediaFormDraft({
    required Iterable<AppContentMedia> persistedMedia,
    required Iterable<PendingContentMediaUpload> pendingUploads,
    required Iterable<String> removedMediaIds,
  }) : persistedMedia = List.unmodifiable(persistedMedia),
       pendingUploads = List.unmodifiable(pendingUploads),
       removedMediaIds = Set.unmodifiable(
         removedMediaIds.map(_cleanId).where((id) => id.isNotEmpty),
       );

  final List<AppContentMedia> persistedMedia;
  final List<PendingContentMediaUpload> pendingUploads;
  final Set<String> removedMediaIds;

  bool get hasMediaChanges {
    return pendingUploads.isNotEmpty || removedMediaIds.isNotEmpty;
  }

  List<AppContentMedia> get visiblePersistedMedia {
    if (removedMediaIds.isEmpty) {
      return persistedMedia;
    }

    return List.unmodifiable(
      persistedMedia.where(
        (media) => !removedMediaIds.contains(_cleanId(media.uuidContentMedia)),
      ),
    );
  }

  List<PendingContentMediaUpload> get visiblePendingUploads {
    final visiblePersistedIds = visiblePersistedMedia
        .map((media) => _cleanId(media.uuidContentMedia))
        .toSet();

    return List.unmodifiable(
      pendingUploads.where(
        (upload) =>
            !visiblePersistedIds.contains(_cleanId(upload.uuidContentMedia)),
      ),
    );
  }

  bool get hasVisiblePublishablePersistedMedia {
    return visiblePersistedMedia.any((media) => media.isPublishable);
  }

  bool get hasPublishableMediaAfterChanges {
    return hasVisiblePublishablePersistedMedia ||
        visiblePendingUploads.isNotEmpty;
  }

  int get nextSortOrder {
    var nextOrder = 0;
    for (final media in visiblePersistedMedia) {
      if (media.orden >= nextOrder) {
        nextOrder = media.orden + 1;
      }
    }
    for (final upload in visiblePendingUploads) {
      if (upload.orden >= nextOrder) {
        nextOrder = upload.orden + 1;
      }
    }
    return nextOrder;
  }
}

class ContentMediaMetadataEdit {
  const ContentMediaMetadataEdit({
    required this.uuidContentMedia,
    required this.titulo,
    required this.duracionSegundos,
  });

  factory ContentMediaMetadataEdit.fromMedia(AppContentMedia media) {
    return ContentMediaMetadataEdit(
      uuidContentMedia: media.uuidContentMedia,
      titulo: media.titulo ?? '',
      duracionSegundos: media.duracionSegundos,
    );
  }

  final String uuidContentMedia;
  final String titulo;
  final int? duracionSegundos;

  ContentMediaMetadataEdit copyWith({
    String? titulo,
    Object? duracionSegundos = _unset,
  }) {
    return ContentMediaMetadataEdit(
      uuidContentMedia: uuidContentMedia,
      titulo: titulo ?? this.titulo,
      duracionSegundos: identical(duracionSegundos, _unset)
          ? this.duracionSegundos
          : duracionSegundos as int?,
    );
  }

  bool hasChangesFrom(AppContentMedia media) {
    return _cleanNullableText(titulo) != _cleanNullableText(media.titulo) ||
        duracionSegundos != media.duracionSegundos;
  }
}

String _cleanId(String value) => value.trim();

String? _cleanNullableText(String? value) {
  final cleanValue = value?.trim();
  if (cleanValue == null || cleanValue.isEmpty) {
    return null;
  }
  return cleanValue;
}
