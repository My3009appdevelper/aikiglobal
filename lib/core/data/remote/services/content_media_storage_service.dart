import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class ContentMediaStorageService {
  ContentMediaStorageService({required SupabaseClient supabase})
    : _supabase = supabase;

  static const bucket = 'content';
  static const signedUrlExpiresInSeconds = 60 * 60;

  final SupabaseClient _supabase;

  Future<String> uploadCover({
    required String uuidContentItem,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final cleanUuid = uuidContentItem.trim();
    if (cleanUuid.isEmpty) {
      throw StateError('No hay contenido válido para subir la portada.');
    }
    if (bytes.isEmpty) {
      throw StateError('La portada seleccionada está vacía.');
    }

    final safeContentType = _contentTypeFor(fileName, contentType);
    final remotePath =
        '$cleanUuid/cover/${DateTime.now().millisecondsSinceEpoch}${_extensionFor(fileName, safeContentType)}';

    await _supabase.storage
        .from(bucket)
        .uploadBinary(
          remotePath,
          bytes,
          fileOptions: FileOptions(upsert: false, contentType: safeContentType),
        );

    return remotePath;
  }

  Future<String> uploadMedia({
    required String uuidContentItem,
    required String uuidContentMedia,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final cleanContentUuid = uuidContentItem.trim();
    final cleanMediaUuid = uuidContentMedia.trim();
    if (cleanContentUuid.isEmpty || cleanMediaUuid.isEmpty) {
      throw StateError('No hay contenido válido para subir el archivo.');
    }
    if (bytes.isEmpty) {
      throw StateError('El archivo seleccionado está vacío.');
    }

    final safeContentType = _mediaContentTypeFor(fileName, contentType);
    final remotePath =
        '$cleanContentUuid/media/$cleanMediaUuid/${DateTime.now().millisecondsSinceEpoch}${_mediaExtensionFor(fileName, safeContentType)}';

    await _supabase.storage
        .from(bucket)
        .uploadBinary(
          remotePath,
          bytes,
          fileOptions: FileOptions(upsert: false, contentType: safeContentType),
        );

    return remotePath;
  }

  Future<void> deleteMedia(String? remotePath) async {
    final cleanPath = remotePath?.trim();
    if (cleanPath == null || cleanPath.isEmpty) {
      return;
    }

    await _supabase.storage.from(bucket).remove([cleanPath]);
  }

  Future<Uint8List?> downloadMedia(String? remotePath) async {
    final cleanPath = remotePath?.trim();
    if (cleanPath == null || cleanPath.isEmpty) {
      return null;
    }

    return _supabase.storage.from(bucket).download(cleanPath);
  }

  Future<String?> createSignedUrl(String? remotePath) async {
    final cleanPath = remotePath?.trim();
    if (cleanPath == null || cleanPath.isEmpty) {
      return null;
    }

    return _supabase.storage
        .from(bucket)
        .createSignedUrl(cleanPath, signedUrlExpiresInSeconds);
  }
}

String _extensionFor(String fileName, String contentType) {
  final cleanName = fileName.trim().toLowerCase();
  final dotIndex = cleanName.lastIndexOf('.');
  if (dotIndex >= 0 && dotIndex < cleanName.length - 1) {
    final extension = cleanName.substring(dotIndex);
    if (const {'.jpg', '.jpeg', '.png', '.webp'}.contains(extension)) {
      return extension == '.jpeg' ? '.jpg' : extension;
    }
  }

  return switch (contentType) {
    'image/png' => '.png',
    'image/webp' => '.webp',
    _ => '.jpg',
  };
}

String _contentTypeFor(String fileName, String? contentType) {
  final cleanContentType = contentType?.trim().toLowerCase();
  if (const {
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
  }.contains(cleanContentType)) {
    return cleanContentType == 'image/jpg' ? 'image/jpeg' : cleanContentType!;
  }

  final cleanName = fileName.trim().toLowerCase();
  if (cleanName.endsWith('.png')) {
    return 'image/png';
  }
  if (cleanName.endsWith('.webp')) {
    return 'image/webp';
  }

  return 'image/jpeg';
}

String _mediaExtensionFor(String fileName, String contentType) {
  final cleanName = fileName.trim().toLowerCase();
  final dotIndex = cleanName.lastIndexOf('.');
  if (dotIndex >= 0 && dotIndex < cleanName.length - 1) {
    final extension = cleanName.substring(dotIndex);
    if (const {
      '.mp4',
      '.mov',
      '.m4v',
      '.mp3',
      '.m4a',
      '.aac',
      '.wav',
      '.ogg',
    }.contains(extension)) {
      return extension;
    }
  }

  return switch (contentType) {
    'video/quicktime' => '.mov',
    'video/x-m4v' => '.m4v',
    'audio/mp4' => '.m4a',
    'audio/aac' => '.aac',
    'audio/wav' => '.wav',
    'audio/ogg' => '.ogg',
    'audio/mpeg' => '.mp3',
    _ => '.mp4',
  };
}

String _mediaContentTypeFor(String fileName, String? contentType) {
  final cleanContentType = contentType?.trim().toLowerCase();
  if (const {
    'video/mp4',
    'video/quicktime',
    'video/x-m4v',
    'audio/mpeg',
    'audio/mp4',
    'audio/aac',
    'audio/wav',
    'audio/ogg',
  }.contains(cleanContentType)) {
    return cleanContentType!;
  }

  final cleanName = fileName.trim().toLowerCase();
  if (cleanName.endsWith('.mov')) {
    return 'video/quicktime';
  }
  if (cleanName.endsWith('.m4v')) {
    return 'video/x-m4v';
  }
  if (cleanName.endsWith('.mp3')) {
    return 'audio/mpeg';
  }
  if (cleanName.endsWith('.m4a')) {
    return 'audio/mp4';
  }
  if (cleanName.endsWith('.aac')) {
    return 'audio/aac';
  }
  if (cleanName.endsWith('.wav')) {
    return 'audio/wav';
  }
  if (cleanName.endsWith('.ogg')) {
    return 'audio/ogg';
  }

  return 'video/mp4';
}
