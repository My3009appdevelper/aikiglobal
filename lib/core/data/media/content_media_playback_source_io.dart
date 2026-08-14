import 'dart:io';

import 'package:video_player/video_player.dart';

Future<VideoPlayerController?> loadLocalContentMediaController(
  String localPath,
) async {
  final file = File(localPath.trim());
  if (!await file.exists()) {
    return null;
  }

  return VideoPlayerController.file(file);
}
