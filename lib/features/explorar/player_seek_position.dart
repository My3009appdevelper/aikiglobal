Duration clampRelativeSeekPosition({
  required Duration position,
  required Duration offset,
  required Duration duration,
}) {
  final targetMilliseconds = (position + offset).inMilliseconds.clamp(
    0,
    duration.inMilliseconds,
  );

  return Duration(milliseconds: targetMilliseconds);
}
