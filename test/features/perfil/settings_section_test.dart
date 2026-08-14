import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/features/perfil/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SettingsSectionFrame usa colorScheme.surface como fondo', (
    tester,
  ) async {
    final scheme = AppTheme.dark.colorScheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: SettingsSectionFrame(child: SizedBox.shrink()),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, scheme.surface);
  });
}
