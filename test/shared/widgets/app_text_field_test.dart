import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppTheme usa surface como fill global de inputs', () {
    expect(
      AppTheme.light.inputDecorationTheme.fillColor,
      AppTheme.light.colorScheme.surface,
    );
    expect(
      AppTheme.dark.inputDecorationTheme.fillColor,
      AppTheme.dark.colorScheme.surface,
    );
  });

  test('AppTheme usa radius 2 en todos los bordes de inputs', () {
    final expectedRadius = BorderRadius.circular(2);

    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final inputTheme = theme.inputDecorationTheme;
      final borders = [
        inputTheme.border,
        inputTheme.enabledBorder,
        inputTheme.focusedBorder,
      ];

      for (final border in borders) {
        expect(border, isA<OutlineInputBorder>());
        expect((border! as OutlineInputBorder).borderRadius, expectedRadius);
      }
    }
  });

  test('AppTheme mantiene labels de inputs en onSurface', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final inputTheme = theme.inputDecorationTheme;
      final expectedColor = theme.colorScheme.onSurface;

      expect(inputTheme.labelStyle?.color, expectedColor);
      expect(inputTheme.floatingLabelStyle?.color, expectedColor);
    }
  });

  testWidgets('shows a persistent label when labelText is provided', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Contenido inicial');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            controller: controller,
            hintText: 'Título',
            labelText: 'Título',
          ),
        ),
      ),
    );

    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Contenido inicial'), findsOneWidget);
  });
}
