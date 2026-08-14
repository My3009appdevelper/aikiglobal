import 'content_media_duration_reader_stub.dart'
    if (dart.library.io) 'content_media_duration_reader_io.dart';

typedef ContentMediaDurationLoader =
    Future<Duration?> Function(String localPath);

class ContentMediaDurationReader {
  const ContentMediaDurationReader({ContentMediaDurationLoader? durationLoader})
    : _durationLoader = durationLoader ?? loadContentMediaDuration;

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
