import 'package:aikiglobal/core/data/models/app_profile.dart';
import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/core/theme/app_typography.dart';
import 'package:aikiglobal/features/admin/admin_users/admin_users_page.dart';
import 'package:aikiglobal/shared/widgets/app_segmented_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget themed(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  testWidgets('AdminUsersHeader usa surface, onSurface y tipografías pedidas', (
    tester,
  ) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      themed(const AdminUsersHeader(total: 24, active: 18)),
    );

    final header = tester.widget<Container>(find.byType(Container).first);
    final decoration = header.decoration! as BoxDecoration;
    expect(decoration.color, scheme.surface);

    final title = tester.widget<Text>(find.text('Usuarios'));
    expect(title.style?.fontFamily, AppTypography.displayFont);
    expect(title.style?.color, scheme.onSurface);

    final description = tester.widget<Text>(
      find.text(
        'Administra miembros, roles y estado de acceso de la comunidad Aiki.',
      ),
    );
    expect(description.style?.fontFamily, AppTypography.primaryFont);
    expect(description.style?.color, scheme.onSurface);

    for (final text in ['24', 'Total']) {
      final widget = tester.widget<Text>(find.text(text));
      expect(widget.style?.fontFamily, AppTypography.displayFont);
      expect(widget.style?.color, scheme.onSurface);
    }

    for (final text in ['18', 'Activos']) {
      final widget = tester.widget<Text>(find.text(text));
      expect(widget.style?.fontFamily, AppTypography.displayFont);
      expect(widget.style?.color, scheme.primary);
      expect(widget.style?.fontWeight, FontWeight.w700);
    }
  });

  testWidgets(
    'AdminUsersSearchField usa surface como la búsqueda de Explorar',
    (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      final scheme = AppTheme.light.colorScheme;

      await tester.pumpWidget(
        themed(
          AdminUsersSearchField(
            controller: controller,
            focusNode: focusNode,
            onChanged: (_) {},
            onTapOutside: (_) {},
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.fillColor, scheme.surface);
    },
  );

  testWidgets('las pestaÃ±as de suscripciÃ³n usan el estilo AIKI compartido', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        AdminSubscriptionTabs(
          products: const [],
          selectedCode: 'none',
          onSelected: (_) {},
        ),
      ),
    );

    expect(find.byType(AppSegmentedTabs), findsOneWidget);
    expect(find.byType(TabBar), findsNothing);
    expect(find.textContaining('Sin'), findsOneWidget);
  });

  testWidgets('AdminUserCard aplica Begum al nombre, chip y racha primary', (
    tester,
  ) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      themed(
        AdminUserCard(
          profile: _profile(
            nombre: 'Ana Ruiz',
            email: 'ana@example.com',
            role: 'admin',
            activo: false,
          ),
          streakDays: 7,
        ),
      ),
    );

    final name = tester.widget<Text>(find.text('Ana Ruiz'));
    expect(name.style?.fontFamily, AppTypography.displayFont);
    expect(name.style?.color, scheme.onSurface);

    final chip = tester.widget<Text>(find.text('Admin'));
    expect(chip.style?.fontFamily, AppTypography.displayFont);

    final fire = tester.widget<Icon>(
      find.byIcon(Icons.local_fire_department_rounded),
    );
    expect(fire.color, scheme.onPrimary);

    final streakBadge = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere((container) => container.constraints?.minWidth == 40);
    final decoration = streakBadge.decoration! as BoxDecoration;
    expect(decoration.color, scheme.primary);

    final streakDays = tester.widget<Text>(find.text('7'));
    expect(streakDays.style?.fontFamily, AppTypography.displayFont);
    expect(streakDays.style?.fontWeight, FontWeight.w300);
  });
}

AppProfile _profile({
  required String nombre,
  required String email,
  required String role,
  required bool activo,
}) {
  final now = DateTime(2026, 7, 16);
  return AppProfile(
    uuidProfile: 'profile-$email',
    authUserId: 'auth-$email',
    nombre: nombre,
    email: email,
    role: role,
    activo: activo,
    onboardingCompletado: true,
    createdAt: now,
    updatedAt: now,
  );
}
