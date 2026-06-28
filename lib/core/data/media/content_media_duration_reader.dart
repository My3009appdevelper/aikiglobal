import 'dart:io';

import 'package:video_player/video_player.dart';

typedef ContentMediaDurationLoader =
    Future<Duration?> Function(String localPath);

class ContentMediaDurationReader {
  const ContentMediaDurationReader({ContentMediaDurationLoader? durationLoader})
    : _durationLoader = durationLoader ?? _loadWithVideoPlayer;

  final ContentMediaDurationLoader _durationLoader;

  Future<int?> readDurationSeconds(String? localPath) async {
    final cleanPath = localPath?.trim();
    if (cleanPath == null || cleanPath.isEmpty) {
      return null;
    }

    try {
      return _secondsFromDuration(await _durationLoader(cleanPath));
    } catch (_) {
      return null;
    }
  }
}

int? _secondsFromDuration(Duration? duration) {
  if (duration == null || duration <= Duration.zero) {
    return null;
  }

  final seconds = (duration.inMilliseconds / 1000).round();
  return seconds <= 0 ? null : seconds;
}

Future<Duration?> _loadWithVideoPlayer(String localPath) async {
  final controller = VideoPlayerController.file(File(localPath));
  try {
    await controller.initialize();
    return controller.value.duration;
  } finally {
    await controller.dispose();
  }
}
