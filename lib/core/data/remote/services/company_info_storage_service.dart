import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

const companyInfoHeroImageSlot = 'hero';

String companyInfoFounderImageSlot(int index) {
  if (index < 1 || index > 5) {
    throw RangeError.range(index, 1, 5, 'index');
  }

  return 'fundadores/$index';
}

class CompanyInfoStorageService {
  CompanyInfoStorageService({required SupabaseClient supabase})
    : _supabase = supabase;

  static const bucket = 'info';
  static const signedUrlExpiresInSeconds = 60 * 60;
  static const imageCacheControlSeconds = '31536000';

  final SupabaseClient _supabase;

  Future<String> uploadImage({
    required String slot,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final cleanSlot = slot.trim();
    if (cleanSlot.isEmpty) {
      throw StateError('No hay una sección válida para subir la imagen.');
    }
    if (bytes.isEmpty) {
      throw StateError('La imagen seleccionada está vacía.');
    }

    final safeContentType = _contentTypeFor(fileName, contentType);
    final remotePath =
        '$cleanSlot/${DateTime.now().millisecondsSinceEpoch}${_extensionFor(fileName, safeContentType)}';

    await _supabase.storage
        .from(bucket)
        .uploadBinary(
          remotePath,
          bytes,
          fileOptions: FileOptions(
            upsert: false,
            contentType: safeContentType,
            cacheControl: imageCacheControlSeconds,
          ),
        );

    return remotePath;
  }

  Future<void> deleteImage(String? remotePath) async {
    final cleanPath = remotePath?.trim();
    if (cleanPath == null || cleanPath.isEmpty) {
      return;
    }

    await _supabase.storage.from(bucket).remove([cleanPath]);
  }

  Future<String?> createSignedUrl(String? remotePath) async {
    final cleanPath = remotePath?.trim();
    if (cleanPath == null || cleanPath.isEmpty) {
      return null;
    }

    try {
      return await _supabase.storage
          .from(bucket)
          .createSignedUrl(cleanPath, signedUrlExpiresInSeconds);
    } on StorageException catch (error) {
      if (error.statusCode == '404') {
        return null;
      }
      rethrow;
    }
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
