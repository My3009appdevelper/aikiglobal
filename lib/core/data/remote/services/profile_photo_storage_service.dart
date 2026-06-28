import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePhotoStorageService {
  ProfilePhotoStorageService({required SupabaseClient supabase})
    : _supabase = supabase;

  static const bucket = 'profiles';
  static const signedUrlExpiresInSeconds = 60 * 60;

  final SupabaseClient _supabase;

  Future<String> uploadProfilePhoto({
    required String authUserId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final cleanAuthUserId = authUserId.trim();
    if (cleanAuthUserId.isEmpty) {
      throw StateError('No hay usuario autenticado para subir la foto.');
    }

    final remotePath =
        '$cleanAuthUserId/avatar_${DateTime.now().millisecondsSinceEpoch}${_extensionFor(fileName, contentType)}';

    await _supabase.storage
        .from(bucket)
        .uploadBinary(
          remotePath,
          bytes,
          fileOptions: FileOptions(
            upsert: false,
            contentType: contentType ?? _contentTypeFor(fileName),
          ),
        );

    return remotePath;
  }

  Future<void> deleteProfilePhoto(String? remotePath) async {
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

    return _supabase.storage
        .from(bucket)
        .createSignedUrl(cleanPath, signedUrlExpiresInSeconds);
  }
}

String _extensionFor(String fileName, String? contentType) {
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

String _contentTypeFor(String fileName) {
  final cleanName = fileName.trim().toLowerCase();
  if (cleanName.endsWith('.png')) {
    return 'image/png';
  }
  if (cleanName.endsWith('.webp')) {
    return 'image/webp';
  }

  return 'image/jpeg';
}
