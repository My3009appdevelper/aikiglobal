import 'package:aikiglobal/features/explorar/content_playback_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('content playback progress', () {
    test(
      'shows continue when content has saved progress and is not completed',
      () {
        final summary = contentPlaybackProgressSummary(
          progresoPorcentaje: 42,
          ultimaPosicionSegundos: 120,
          completado: false,
          showsMediaStages: false,
        );

        expect(summary.buttonLabel, 'Continuar');
        expect(summary.statusText, 'Vas en 42%');
      },
    );

    test('shows completed state when content is completed', () {
      final summary = contentPlaybackProgressSummary(
        progresoPorcentaje: 100,
        ultimaPosicionSegundos: 500,
        completado: true,
        showsMediaStages: false,
      );

      expect(summary.buttonLabel, 'Reproducir de nuevo');
      expect(summary.statusText, 'Contenido completado');
    });

    test('keeps default course action when there is no saved progress', () {
      final summary = contentPlaybackProgressSummary(
        progresoPorcentaje: 0,
        ultimaPosicionSegundos: 0,
        completado: false,
        showsMediaStages: true,
      );

      expect(summary.buttonLabel, 'Comenzar curso');
      expect(summary.statusText, isNull);
    });

    test('calculates progress percentage from playback position', () {
      expect(
        playbackProgressPercentage(
          position: const Duration(seconds: 42),
          duration: const Duration(seconds: 100),
        ),
        42,
      );
    });

    test('marks playback completed at 95 percent', () {
      expect(
        shouldMarkPlaybackCompleted(
          position: const Duration(seconds: 95),
          duration: const Duration(seconds: 100),
        ),
        isTrue,
      );
    });

    test('returns card progress only when content has progress', () {
      expect(
        contentCardProgressPercentage(
          progresoPorcentaje: 0,
          ultimaPosicionSegundos: 0,
          completado: false,
        ),
        isNull,
      );
      expect(
        contentCardProgressPercentage(
          progresoPorcentaje: 42,
          ultimaPosicionSegundos: 120,
          completado: false,
        ),
        42,
      );
      expect(
        contentCardProgressPercentage(
          progresoPorcentaje: 25,
          ultimaPosicionSegundos: 120,
          completado: true,
        ),
        100,
      );
    });
  });
}
