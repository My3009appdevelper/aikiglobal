import 'package:aikiglobal/features/explorar/player_autoplay_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps initial autoplay pending until a media is prepared', () {
    expect(
      shouldRequestAutoplayOnMediaSync(initialAutoplayConsumed: false),
      isTrue,
    );
    expect(
      shouldConsumeInitialAutoplay(
        requestedAutoplay: true,
        mediaPrepared: false,
      ),
      isFalse,
    );
  });

  test('consumes initial autoplay only after successful preparation', () {
    expect(
      shouldConsumeInitialAutoplay(
        requestedAutoplay: true,
        mediaPrepared: true,
      ),
      isTrue,
    );
    expect(
      shouldRequestAutoplayOnMediaSync(initialAutoplayConsumed: true),
      isFalse,
    );
  });

  test('manual non-autoplay preparation does not consume initial autoplay', () {
    expect(
      shouldConsumeInitialAutoplay(
        requestedAutoplay: false,
        mediaPrepared: true,
      ),
      isFalse,
    );
  });
}
