String contentMediaDurationSecondsToMinutesText(int? seconds) {
  if (seconds == null || seconds <= 0) {
    return '';
  }

  final minutes = seconds / 60;
  if (seconds % 60 == 0) {
    return minutes.toInt().toString();
  }

  return minutes
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

int? contentMediaDurationMinutesTextToSeconds(String value) {
  final cleanValue = value.trim().replaceAll(',', '.');
  if (cleanValue.isEmpty) {
    return null;
  }

  final minutes = double.tryParse(cleanValue);
  if (minutes == null || minutes <= 0) {
    return null;
  }

  final seconds = (minutes * 60).round();
  return seconds <= 0 ? null : seconds;
}
