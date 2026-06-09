import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageObjectNotFoundException implements Exception {
  StorageObjectNotFoundException(this.message);

  final String message;

  @override
  String toString() => 'StorageObjectNotFoundException: $message';
}

class StorageTemporaryException implements Exception {
  StorageTemporaryException(this.message);

  final String message;

  @override
  String toString() => 'StorageTemporaryException: $message';
}

class StorageUnknownException implements Exception {
  StorageUnknownException(this.message);

  final String message;

  @override
  String toString() => 'StorageUnknownException: $message';
}

class BaseStorageService {
  BaseStorageService({
    required this.bucket,
    required this.logTag,
    SupabaseClient? supabase,
    this.requireAuthForDownload = true,
  }) : supabase = _resolveSupabaseClient(supabase);

  final SupabaseClient supabase;
  final String bucket;
  final String logTag;
  final bool requireAuthForDownload;

  static SupabaseClient _resolveSupabaseClient(SupabaseClient? client) {
    if (client != null) {
      return client;
    }

    throw StateError(
      'No hay cliente de Supabase inyectado en BaseStorageService. '
      'Inicializa Supabase en el arranque y pasa supabase desde el punto único de composición.',
    );
  }

  Future<String> calculateSha256(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  String normalizeRemotePath(String remotePath) {
    final clean = remotePath.trim();
    final fromUrl = _remotePathFromSupabaseUrl(clean);
    final noLeading = fromUrl.replaceFirst(RegExp(r'^/+'), '');
    return noLeading.replaceAll(RegExp(r'/+'), '/');
  }

  String safeLocalFileNameFromRemotePath(String remotePath) {
    return normalizeRemotePath(remotePath).replaceAll('/', '_');
  }

  String guessContentTypeByExt(String value) {
    switch (path.extension(value).toLowerCase()) {
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      case '.svg':
        return 'image/svg+xml';
      case '.mp3':
        return 'audio/mpeg';
      case '.mp4':
        return 'video/mp4';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  Future<bool> existsRemoteFile(String remotePath) async {
    final clean = normalizeRemotePath(remotePath);
    if (clean.isEmpty) {
      return false;
    }

    final directory = path.dirname(clean);
    final fileName = path.basename(clean);
    final storageDirectory = directory == '.' ? '' : directory;

    try {
      final items = await supabase.storage.from(bucket).list(path: storageDirectory);
      return items.any((item) => item.name == fileName);
    } catch (error) {
      log('existsRemoteFile error=$error remote=$clean', name: logTag);
      return false;
    }
  }

  Future<void> uploadFile(
    File file,
    String remotePath, {
    bool overwrite = false,
  }) async {
    final clean = normalizeRemotePath(remotePath);
    await supabase.storage.from(bucket).upload(
          clean,
          file,
          fileOptions: FileOptions(
            upsert: overwrite,
            contentType: guessContentTypeByExt(clean),
          ),
        );
  }

  Future<void> deleteRemoteFileSafe(String remotePath) async {
    final clean = normalizeRemotePath(remotePath);
    if (clean.isEmpty) {
      return;
    }

    try {
      await supabase.storage.from(bucket).remove([clean]);
    } catch (error) {
      log('deleteRemoteFileSafe error=$error remote=$clean', name: logTag);
    }
  }

  Future<Directory> ensureLocalDir(String localDirName) async {
    final baseDir = await getApplicationSupportDirectory();
    final directory = Directory(path.join(baseDir.path, localDirName));

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  Future<File> buildCanonicalLocalFile(
    String remotePath, {
    required String localDirName,
  }) async {
    final directory = await ensureLocalDir(localDirName);
    final fileName = safeLocalFileNameFromRemotePath(remotePath);
    return File(path.join(directory.path, fileName));
  }

  Future<File?> getCanonicalLocalFileIfExists(
    String remotePath, {
    required String localDirName,
  }) async {
    final file = await buildCanonicalLocalFile(remotePath, localDirName: localDirName);
    return await file.exists() ? file : null;
  }

  Future<File?> downloadFile(
    String remotePath, {
    required String localDirName,
  }) async {
    final clean = normalizeRemotePath(remotePath);
    if (clean.isEmpty) {
      return null;
    }

    if (requireAuthForDownload) {
      final hasSession = await _waitForAuthSession();
      if (!hasSession) {
        throw StorageTemporaryException('Auth session is not ready for "$clean".');
      }
    }

    try {
      final bytes = await supabase.storage.from(bucket).download(clean);
      final file = await buildCanonicalLocalFile(clean, localDirName: localDirName);
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } on StorageException catch (error) {
      final status = error.statusCode?.toString();
      final message = error.message.toLowerCase();
      final notFound = status == '404' || message.contains('not found');

      if (notFound) {
        throw StorageObjectNotFoundException('Missing "$clean" in bucket "$bucket".');
      }

      throw StorageTemporaryException(
        'Storage status=$status downloading "$clean" from bucket "$bucket".',
      );
    } catch (error) {
      throw StorageUnknownException('Unknown storage error for "$clean": $error');
    }
  }

  String? getPublicUrl(String remotePath) {
    final clean = normalizeRemotePath(remotePath);
    if (clean.isEmpty) {
      return null;
    }

    return supabase.storage.from(bucket).getPublicUrl(clean);
  }

  String _remotePathFromSupabaseUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      return value;
    }

    final segments = uri.pathSegments;
    final objectIndex = segments.indexOf('object');
    if (objectIndex < 0) {
      return value;
    }

    var pathIndex = objectIndex + 1;
    if (pathIndex < segments.length &&
        const {'authenticated', 'public', 'sign'}.contains(segments[pathIndex])) {
      pathIndex++;
    }

    if (pathIndex >= segments.length) {
      return value;
    }

    final urlBucket = Uri.decodeComponent(segments[pathIndex]);
    if (urlBucket != bucket) {
      return value;
    }

    pathIndex++;
    if (pathIndex >= segments.length) {
      return '';
    }

    return segments.sublist(pathIndex).map(Uri.decodeComponent).join('/');
  }

  Future<bool> _waitForAuthSession({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    if (supabase.auth.currentSession != null) {
      return true;
    }

    final completer = Completer<bool>();
    late final StreamSubscription<AuthState> subscription;
    Timer? timer;

    void complete(bool value) {
      if (!completer.isCompleted) {
        completer.complete(value);
      }
    }

    subscription = supabase.auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        complete(true);
      }
    });

    timer = Timer(timeout, () {
      complete(supabase.auth.currentSession != null);
    });

    final ready = await completer.future;
    await subscription.cancel();
    timer.cancel();
    return ready || supabase.auth.currentSession != null;
  }
}
