class ContentMediaSaveMetadata {
  const ContentMediaSaveMetadata({
    required this.title,
    required this.durationSeconds,
  });

  final String title;
  final int? durationSeconds;
}

bool contentMediaMetadataIsEditable(String contentType) {
  return contentType.trim().toLowerCase() == 'course';
}

ContentMediaSaveMetadata contentMediaMetadataForSave({
  required String contentType,
  required String contentTitle,
  required int? contentDurationSeconds,
  required String mediaTitle,
  required int? mediaDurationSeconds,
}) {
  if (contentMediaMetadataIsEditable(contentType)) {
    return ContentMediaSaveMetadata(
      title: mediaTitle.trim(),
      durationSeconds: mediaDurationSeconds,
    );
  }

  return ContentMediaSaveMetadata(
    title: contentTitle.trim(),
    durationSeconds: contentDurationSeconds,
  );
}
