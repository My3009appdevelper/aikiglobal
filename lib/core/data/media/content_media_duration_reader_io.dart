import 'dart:io';

import 'package:video_player/video_player.dart';

Future<Duration?> loadContentMediaDuration(String localPath) async {
  final controller = VideoPlayerController.file(File(localPath));
  try {
    await controller.initialize();
    return controller.value.duration;
  } finally {
    await controller.dispose();
  }
}
