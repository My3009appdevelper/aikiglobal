import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/core/theme/app_typography.dart';
import 'package:aikiglobal/shared/widgets/app_content_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget themed(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  testWidgets('usa tokens solicitados en texto, chips e iconos', (
    tester,
  ) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      themed(
        const AppContentCard(
          imageAsset: '',
          title: 'Respira y suelta',
          subtitle: 'Meditación · 12 min',
          badge: 'Meditación',
        ),
      ),
    );

    final badge = tester.widget<Text>(find.text('Meditación'));
    expect(badge.style?.fontFamily, AppTypography.displayFont);
    expect(badge.style?.color, scheme.onSurface);

    final title = tester.widget<Text>(find.text('Respira y suelta'));
    expect(title.style?.fontFamily, AppTypography.displayFont);
    expect(title.style?.color, scheme.onSurface);

    final durationIcon = tester.widget<Icon>(
      find.byIcon(Icons.access_time_rounded),
    );
    expect(durationIcon.color, scheme.primary);

    final favoriteIcon = tester.widget<Icon>(
      find.byIcon(Icons.bookmark_border_rounded),
    );
    expect(favoriteIcon.color, scheme.primary);
  });

  testWidgets('muestra progreso cuando el contenido ya fue iniciado', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        const AppContentCard(
          imageAsset: '',
          title: 'Respira y suelta',
          subtitle: 'Meditación · 12 min',
          progressPercentage: 42,
        ),
      ),
    );

    expect(find.text('42%'), findsOneWidget);
  });
}
