bool shouldShowPlayerStageControls({
  required bool controlsRequested,
  required bool isPreparing,
  required bool isLoadingMedia,
  required bool hasSelectedMedia,
  required bool isPlaying,
  required bool hasPlaybackError,
}) {
  if (hasPlaybackError) {
    return true;
  }

  if (isPreparing || (isLoadingMedia && !hasSelectedMedia)) {
    return true;
  }

  if (!isPlaying) {
    return true;
  }

  return controlsRequested;
}
