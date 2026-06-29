import 'package:aikiglobal/features/explorar/player_seek_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clamps relative seek between zero and video duration', () {
    expect(
      clampRelativeSeekPosition(
        position: const Duration(seconds: 5),
        offset: const Duration(seconds: -10),
        duration: const Duration(minutes: 2),
      ),
      Duration.zero,
    );

    expect(
      clampRelativeSeekPosition(
        position: const Duration(minutes: 1, seconds: 55),
        offset: const Duration(seconds: 10),
        duration: const Duration(minutes: 2),
      ),
      const Duration(minutes: 2),
    );

    expect(
      clampRelativeSeekPosition(
        position: const Duration(seconds: 30),
        offset: const Duration(seconds: 10),
        duration: const Duration(minutes: 2),
      ),
      const Duration(seconds: 40),
    );
  });
}
