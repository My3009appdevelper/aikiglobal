import 'package:aikiglobal/core/data/media/content_media_duration_reader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('readDurationSeconds rounds loaded media duration to seconds', () async {
    final reader = ContentMediaDurationReader(
      durationLoader: (_) async => const Duration(milliseconds: 90500),
    );

    expect(await reader.readDurationSeconds('C:/media/clase.mp4'), 91);
  });

  test('readDurationSeconds ignores empty paths', () async {
    var calls = 0;
    final reader = ContentMediaDurationReader(
      durationLoader: (_) async {
        calls++;
        return const Duration(seconds: 30);
      },
    );

    expect(await reader.readDurationSeconds('  '), isNull);
    expect(calls, 0);
  });
}
