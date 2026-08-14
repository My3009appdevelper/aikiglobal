import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/core/theme/app_colors.dart';
import 'package:aikiglobal/core/theme/app_typography.dart';
import 'package:aikiglobal/features/perfil/widgets/subscription_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('usa los tokens de color y tipografía solicitados', (
    tester,
  ) async {
    final scheme = AppTheme.dark.colorScheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: SubscriptionCard()),
      ),
    );

    final card = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere((container) => container.constraints?.maxHeight == 256);
    final cardDecoration = card.decoration as BoxDecoration;
    expect(cardDecoration.color, isNull);

    final cardSize = tester.getSize(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is Container && widget.constraints?.maxHeight == 256,
          )
          .first,
    );
    final backgroundImageSize = tester.getSize(find.byType(Image).first);
    expect(backgroundImageSize, cardSize);

    final gradients = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration as BoxDecoration)
        .map((decoration) => decoration.gradient)
        .whereType<LinearGradient>()
        .toList();
    expect(gradients, hasLength(1));
    expect(gradients.single.colors, [
      scheme.surface.withValues(alpha: 0.96),
      scheme.surface.withValues(alpha: 0.72),
      AppColors.transparent,
    ]);

    final activeTitle = tester.widget<Text>(find.text('Suscripción activa'));
    expect(activeTitle.style?.fontFamily, AppTypography.displayFont);
    expect(activeTitle.style?.color, scheme.onSurface);

    final planTitle = tester.widget<Text>(find.text('Plan Esencial'));
    expect(planTitle.style?.fontFamily, AppTypography.displayFont);
    expect(planTitle.style?.color, scheme.primary);

    final memberSince = tester.widget<Text>(
      find.text('Miembro desde enero 2024'),
    );
    expect(memberSince.style?.color, scheme.primary);

    final renewal = tester.widget<Text>(
      find.text('Renovación automática el\n12 de junio de 2025'),
    );
    expect(renewal.style?.color, scheme.onSurface);

    final buttonLabel = tester.widget<Text>(find.text('Gestionar plan'));
    expect(buttonLabel.style?.fontFamily, AppTypography.displayFont);
    expect(buttonLabel.style?.color, scheme.onPrimary);

    final buttonContainer = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere((container) => container.constraints?.maxHeight == 44);
    final buttonDecoration = buttonContainer.decoration as BoxDecoration;
    expect(buttonDecoration.color, scheme.primary);
  });
}
