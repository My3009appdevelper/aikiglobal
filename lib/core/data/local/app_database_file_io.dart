import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> prepareLocalDatabasePath({
  required String name,
  required bool reset,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  final databasePath = path.join(directory.path, '$name.sqlite');

  if (reset) {
    await _deleteIfExists(databasePath);
    await _deleteIfExists('$databasePath-wal');
    await _deleteIfExists('$databasePath-shm');
  }

  return databasePath;
}

Future<void> _deleteIfExists(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    await file.delete();
  }
}
