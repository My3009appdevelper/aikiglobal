import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/features/perfil/perfil_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('usa onSurface en el titulo Configuración', (tester) async {
    final scheme = AppTheme.dark.colorScheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: PerfilConfigurationTitle()),
      ),
    );

    final title = tester.widget<Text>(find.text('Configuración'));
    expect(title.style?.color, scheme.onSurface);
  });
}
