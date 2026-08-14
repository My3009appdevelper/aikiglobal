import 'package:aikiglobal/core/theme/app_colors.dart';
import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/shared/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget themed(Widget child, {ThemeData? theme}) {
    final effectiveTheme = theme ?? AppTheme.light;

    return MaterialApp(
      theme: AppTheme.light,
      home: Theme(
        data: effectiveTheme,
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('usa surface/onSurface en light y dark', (tester) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final scheme = theme.colorScheme;

      await tester.pumpWidget(
        themed(AppBackButton(onTap: () {}), theme: theme),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AppBackButton),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, scheme.surface);

      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(AppBackButton),
          matching: find.byIcon(Icons.arrow_back_rounded),
        ),
      );
      expect(icon.color, scheme.onSurface);
      expect(icon.size, 32);
    }
  });

  testWidgets('mantiene variante overlay con icono blanco', (tester) async {
    await tester.pumpWidget(
      themed(AppBackButton.overlay(onTap: () {}), theme: AppTheme.dark),
    );

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AppBackButton),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.black.withValues(alpha: 0.28));

    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byType(AppBackButton),
        matching: find.byIcon(Icons.arrow_back_rounded),
      ),
    );
    expect(icon.color, AppColors.white);
  });

  testWidgets('ejecuta onTap cuando esta habilitado', (tester) async {
    var tapped = false;

    await tester.pumpWidget(themed(AppBackButton(onTap: () => tapped = true)));
    await tester.tap(find.byType(AppBackButton));

    expect(tapped, isTrue);
  });
}
