import 'dart:typed_data';

class LocalMediaCache {
  const LocalMediaCache();

  Future<String?> canonicalPath({
    required String namespace,
    required String remotePath,
  }) async {
    return null;
  }

  Future<String?> writeBytes({
    required String namespace,
    required String remotePath,
    required Uint8List bytes,
  }) async {
    return null;
  }

  Future<bool> exists(String? localPath) async {
    return false;
  }

  Future<void> delete(String? localPath) async {}
}
