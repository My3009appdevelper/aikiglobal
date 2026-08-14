import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/core/theme/app_typography.dart';
import 'package:aikiglobal/shared/widgets/app_setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('usa onSurface y las tipografías solicitadas en textos', (
    tester,
  ) async {
    final scheme = AppTheme.dark.colorScheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: Column(
            children: [
              AppSettingTile(
                icon: Icons.person_outline_rounded,
                title: 'Datos personales',
                subtitle: 'Gestiona tu información personal',
              ),
              AppSettingTile(
                icon: Icons.logout_rounded,
                title: 'Cerrar sesión',
                subtitle: 'Salir de tu cuenta de Aiki',
              ),
            ],
          ),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text('Datos personales'));
    expect(title.style?.fontFamily, AppTypography.displayFont);
    expect(title.style?.color, scheme.onSurface);

    final subtitle = tester.widget<Text>(
      find.text('Gestiona tu información personal'),
    );
    expect(subtitle.style?.fontFamily, AppTypography.primaryFont);
    expect(subtitle.style?.color, scheme.onSurface);

    final logoutTitle = tester.widget<Text>(find.text('Cerrar sesión'));
    expect(logoutTitle.style?.color, scheme.onSurface);

    final normalIcon = tester
        .widgetList<Icon>(find.byIcon(Icons.person_outline_rounded))
        .firstWhere((icon) => icon.color != null);
    final logoutIcon = tester
        .widgetList<Icon>(find.byIcon(Icons.logout_rounded))
        .firstWhere((icon) => icon.color != null);
    expect(normalIcon.color, scheme.onPrimary);
    expect(logoutIcon.color, normalIcon.color);

    final iconContainers = tester
        .widgetList<Container>(find.byType(Container))
        .where((container) => container.constraints?.maxWidth == 48)
        .map((container) => container.decoration as BoxDecoration)
        .toList();
    expect(iconContainers, hasLength(2));
    expect(iconContainers.first.color, scheme.primary);
    expect(iconContainers.last.color, iconContainers.first.color);
  });
}
