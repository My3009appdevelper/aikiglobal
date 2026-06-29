import 'content_media_file_metadata.dart';

const maxVideoUploadBytes = 500 * 1024 * 1024;
const maxAudioUploadBytes = 200 * 1024 * 1024;

String? validateContentMediaFileSize({
  required String tipo,
  required int sizeBytes,
}) {
  if (sizeBytes <= 0) {
    return null;
  }

  final cleanType = tipo.trim().toLowerCase();
  if (ContentMediaFileMetadata.isVideoType(cleanType)) {
    return sizeBytes > maxVideoUploadBytes
        ? 'El video seleccionado supera el límite de 500 MB.'
        : null;
  }

  return sizeBytes > maxAudioUploadBytes
      ? 'El audio seleccionado supera el límite de 200 MB.'
      : null;
}
