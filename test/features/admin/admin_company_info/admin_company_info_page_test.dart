import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/core/theme/app_typography.dart';
import 'package:aikiglobal/features/admin/admin_company_info/admin_company_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget themed(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  testWidgets('AdminCompanyInfoHeader usa surface, onSurface y tipografías', (
    tester,
  ) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      themed(
        const AdminCompanyInfoHeader(
          isLoading: false,
          isSyncing: false,
          isPending: false,
        ),
      ),
    );

    final header = tester.widget<Container>(find.byType(Container).first);
    final decoration = header.decoration! as BoxDecoration;
    expect(decoration.color, scheme.surface);

    final title = tester.widget<Text>(find.textContaining('Informaci'));
    expect(title.style?.fontFamily, AppTypography.displayFont);
    expect(title.style?.color, scheme.onSurface);

    final description = tester.widget<Text>(find.textContaining('Edita'));
    expect(description.style?.fontFamily, AppTypography.primaryFont);
    expect(description.style?.color, scheme.onSurface);
  });

  testWidgets('AdminCompanyInfoCard usa colorScheme.surface como fondo', (
    tester,
  ) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      themed(const AdminCompanyInfoCard(child: Text('Contenido'))),
    );

    final card = tester.widget<Container>(find.byType(Container).first);
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.color, scheme.surface);
  });

  testWidgets('AdminCompanyInfoTabbedCard separa Hero, Fundadores y Aiki', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        const AdminCompanyInfoTabbedCard(
          hero: Text('Campos del hero'),
          fundadores: Text('Campos de fundadores'),
          aiki: Text('Campos de Aiki'),
        ),
      ),
    );

    expect(find.text('Hero'), findsOneWidget);
    expect(find.text('Fundadores'), findsOneWidget);
    expect(find.text('Aiki'), findsOneWidget);
    expect(find.text('Campos del hero'), findsOneWidget);
    expect(find.text('Campos de fundadores'), findsNothing);
    expect(find.text('Campos de Aiki'), findsNothing);

    await tester.tap(find.text('Fundadores'));
    await tester.pumpAndSettle();

    expect(find.text('Campos del hero'), findsNothing);
    expect(find.text('Campos de fundadores'), findsOneWidget);
    expect(find.text('Campos de Aiki'), findsNothing);

    await tester.tap(find.text('Aiki'));
    await tester.pumpAndSettle();

    expect(find.text('Campos del hero'), findsNothing);
    expect(find.text('Campos de fundadores'), findsNothing);
    expect(find.text('Campos de Aiki'), findsOneWidget);
  });

  testWidgets('AdminCompanyInfoSaveButton usa Begum en el label', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(AdminCompanyInfoSaveButton(onPressed: () {})),
    );

    final label = tester.widget<Text>(find.text('Guardar cambios'));
    expect(label.style?.fontFamily, AppTypography.displayFont);
  });
}
