import 'package:aikiglobal/features/explorar/player_stage_controls_visibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hides stage controls while playing until the user asks for them', () {
    expect(
      shouldShowPlayerStageControls(
        controlsRequested: false,
        isPreparing: false,
        isLoadingMedia: false,
        hasSelectedMedia: true,
        isPlaying: true,
        hasPlaybackError: false,
      ),
      isFalse,
    );

    expect(
      shouldShowPlayerStageControls(
        controlsRequested: true,
        isPreparing: false,
        isLoadingMedia: false,
        hasSelectedMedia: true,
        isPlaying: true,
        hasPlaybackError: false,
      ),
      isTrue,
    );
  });

  test('keeps stage controls visible when playback is not cleanly playing', () {
    expect(
      shouldShowPlayerStageControls(
        controlsRequested: false,
        isPreparing: false,
        isLoadingMedia: false,
        hasSelectedMedia: true,
        isPlaying: false,
        hasPlaybackError: false,
      ),
      isTrue,
    );

    expect(
      shouldShowPlayerStageControls(
        controlsRequested: false,
        isPreparing: true,
        isLoadingMedia: false,
        hasSelectedMedia: true,
        isPlaying: true,
        hasPlaybackError: false,
      ),
      isTrue,
    );

    expect(
      shouldShowPlayerStageControls(
        controlsRequested: false,
        isPreparing: false,
        isLoadingMedia: false,
        hasSelectedMedia: true,
        isPlaying: true,
        hasPlaybackError: true,
      ),
      isTrue,
    );
  });
}
