import 'package:video_player/video_player.dart';

import 'content_media_playback_source_stub.dart'
    if (dart.library.io) 'content_media_playback_source_io.dart';

Future<VideoPlayerController?> createLocalContentMediaController(
  String localPath,
) {
  return loadLocalContentMediaController(localPath);
}
