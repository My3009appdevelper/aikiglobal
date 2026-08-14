import 'package:aikiglobal/app/aiki_app.dart';
import 'package:aikiglobal/app/aiki_theme_host.dart';
import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/core/theme/app_theme_controller.dart';
import 'package:aikiglobal/features/perfil/widgets/theme_mode_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('primer tap de theme no mueve el scroll que contiene el switch', (
    tester,
  ) async {
    final themeController = AppThemeController();
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      AppThemeScope(
        controller: themeController,
        child: MaterialApp(
          theme: AppTheme.light,
          home: AikiThemeHost(
            controller: themeController,
            child: Scaffold(
              body: SingleChildScrollView(
                controller: scrollController,
                child: const Column(
                  children: [
                    SizedBox(height: 700),
                    ThemeModeTile(),
                    SizedBox(height: 700),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.byTooltip('Tema oscuro'));
    await tester.pump();
    final offsetBeforeTap = scrollController.offset;

    await tester.tap(find.byTooltip('Tema oscuro'));
    await tester.pump();

    expect(scrollController.offset, offsetBeforeTap);
  });
}
