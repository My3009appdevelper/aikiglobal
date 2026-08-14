import 'package:aikiglobal/app/aiki_app.dart';
import 'package:aikiglobal/core/theme/app_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('theme scope readers do not rebuild on theme changes', (
    tester,
  ) async {
    final controller = AppThemeController();
    var buildCount = 0;

    await tester.pumpWidget(
      AppThemeScope(
        controller: controller,
        child: Builder(
          builder: (context) {
            buildCount += 1;
            AppThemeScope.of(context);
            return const Directionality(
              textDirection: TextDirection.ltr,
              child: Text('Theme reader'),
            );
          },
        ),
      ),
    );

    expect(buildCount, 1);

    controller.setThemeMode(ThemeMode.dark);
    await tester.pump();

    expect(buildCount, 1);
  });
}
