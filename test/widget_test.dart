import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/features/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra la pantalla de login mock', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LoginPage()),
    );

    expect(find.text('Bienvenido a Aiki'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
