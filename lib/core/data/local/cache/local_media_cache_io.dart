import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class LocalMediaCache {
  const LocalMediaCache();

  static const _rootDirectoryName = 'aiki_media_cache';

  Future<String?> canonicalPath({
    required String namespace,
    required String remotePath,
  }) async {
    final cleanRemotePath = remotePath.trim();
    if (cleanRemotePath.isEmpty) {
      return null;
    }

    final directory = await _ensureNamespaceDirectory(namespace);
    return path.join(directory.path, _safeFileName(cleanRemotePath));
  }

  Future<String?> writeBytes({
    required String namespace,
    required String remotePath,
    required Uint8List bytes,
  }) async {
    if (bytes.isEmpty) {
      return null;
    }

    final filePath = await canonicalPath(
      namespace: namespace,
      remotePath: remotePath,
    );
    if (filePath == null) {
      return null;
    }

    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<String?> copyFile({
    required String namespace,
    required String remotePath,
    required String localPath,
  }) async {
    final cleanPath = _cleanLocalPath(localPath);
    if (cleanPath == null) {
      return null;
    }

    final filePath = await canonicalPath(
      namespace: namespace,
      remotePath: remotePath,
    );
    if (filePath == null) {
      return null;
    }

    final sourceFile = File(cleanPath);
    if (!await sourceFile.exists()) {
      return null;
    }

    final cachedFile = await sourceFile.copy(filePath);
    return cachedFile.path;
  }

  Future<bool> exists(String? localPath) async {
    final cleanPath = _cleanLocalPath(localPath);
    if (cleanPath == null) {
      return false;
    }

    return File(cleanPath).exists();
  }

  Future<void> delete(String? localPath) async {
    final cleanPath = _cleanLocalPath(localPath);
    if (cleanPath == null) {
      return;
    }

    final file = File(cleanPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _ensureNamespaceDirectory(String namespace) async {
    final baseDirectory = await getApplicationSupportDirectory();
    final directory = Directory(
      path.join(
        baseDirectory.path,
        _rootDirectoryName,
        _safeDirectoryName(namespace),
      ),
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }
}

String _safeDirectoryName(String value) {
  return value.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
}

String _safeFileName(String remotePath) {
  final safeName = remotePath
      .trim()
      .replaceAll(RegExp(r'^/+'), '')
      .replaceAll(RegExp(r'[/\\]+'), '_')
      .replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');

  if (safeName.isEmpty) {
    return 'media_file';
  }

  return safeName;
}

String? _cleanLocalPath(String? localPath) {
  final cleanPath = localPath?.trim();
  if (cleanPath == null || cleanPath.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(cleanPath);
  if (uri != null && uri.scheme == 'file') {
    return uri.toFilePath();
  }

  return cleanPath;
}
