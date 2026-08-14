class ContentPlaybackProgressSummary {
  const ContentPlaybackProgressSummary({
    required this.buttonLabel,
    required this.statusText,
    required this.hasSavedProgress,
    required this.isCompleted,
  });

  final String buttonLabel;
  final String? statusText;
  final bool hasSavedProgress;
  final bool isCompleted;
}

ContentPlaybackProgressSummary contentPlaybackProgressSummary({
  required int progresoPorcentaje,
  required int ultimaPosicionSegundos,
  required bool completado,
  required bool showsMediaStages,
}) {
  if (completado) {
    return const ContentPlaybackProgressSummary(
      buttonLabel: 'Reproducir de nuevo',
      statusText: 'Contenido completado',
      hasSavedProgress: false,
      isCompleted: true,
    );
  }

  final hasSavedProgress = ultimaPosicionSegundos > 0;
  if (hasSavedProgress) {
    final displayProgress = progresoPorcentaje.clamp(1, 99).toInt();
    return ContentPlaybackProgressSummary(
      buttonLabel: 'Continuar',
      statusText: 'Vas en $displayProgress%',
      hasSavedProgress: true,
      isCompleted: false,
    );
  }

  return ContentPlaybackProgressSummary(
    buttonLabel: showsMediaStages ? 'Comenzar curso' : 'Reproducir ahora',
    statusText: null,
    hasSavedProgress: false,
    isCompleted: false,
  );
}

int playbackProgressPercentage({
  required Duration position,
  required Duration duration,
}) {
  final durationMilliseconds = duration.inMilliseconds;
  if (durationMilliseconds <= 0) {
    return 0;
  }

  final cleanPosition = position.inMilliseconds.clamp(0, durationMilliseconds);
  final percentage = cleanPosition / durationMilliseconds * 100;
  return percentage.round().clamp(0, 100).toInt();
}

bool shouldMarkPlaybackCompleted({
  required Duration position,
  required Duration duration,
}) {
  final durationMilliseconds = duration.inMilliseconds;
  if (durationMilliseconds <= 0) {
    return false;
  }

  final cleanPosition = position.inMilliseconds.clamp(0, durationMilliseconds);
  return cleanPosition >= durationMilliseconds * 0.95;
}

bool shouldSavePlaybackProgress({
  required Duration position,
  required int? lastSavedPositionSeconds,
  Duration interval = const Duration(seconds: 10),
}) {
  final positionSeconds = position.inSeconds;
  if (positionSeconds <= 0) {
    return false;
  }

  if (lastSavedPositionSeconds == null || lastSavedPositionSeconds < 0) {
    return true;
  }

  final intervalSeconds = interval.inSeconds;
  if (intervalSeconds <= 0) {
    return true;
  }

  return (positionSeconds - lastSavedPositionSeconds).abs() >= intervalSeconds;
}

int? contentCardProgressPercentage({
  required int progresoPorcentaje,
  required int ultimaPosicionSegundos,
  required bool completado,
}) {
  if (completado) {
    return 100;
  }

  if (ultimaPosicionSegundos <= 0) {
    return null;
  }

  return progresoPorcentaje.clamp(1, 99).toInt();
}
