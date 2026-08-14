import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/core/theme/app_typography.dart';
import 'package:aikiglobal/core/data/models/app_content_item.dart';
import 'package:aikiglobal/features/admin/admin_content/admin_content_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget themed(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  testWidgets('AdminContentHeader usa surface, onSurface y tipografías', (
    tester,
  ) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      themed(
        const AdminContentHeader(
          total: 24,
          published: 8,
          drafts: 11,
          archived: 5,
        ),
      ),
    );

    final header = tester.widget<Container>(find.byType(Container).first);
    final decoration = header.decoration! as BoxDecoration;
    expect(decoration.color, scheme.surface);

    final title = tester.widget<Text>(find.text('Contenido'));
    expect(title.style?.fontFamily, AppTypography.displayFont);
    expect(title.style?.color, scheme.onSurface);

    final subtitle = tester.widget<Text>(
      find.text('Administra publicaciones, borradores y contenido archivado.'),
    );
    expect(subtitle.style?.fontFamily, AppTypography.primaryFont);
    expect(subtitle.style?.color, scheme.onSurface);

    for (final text in ['24', 'Total', '11', 'Borradores', '5', 'Archivado']) {
      final widget = tester.widget<Text>(find.text(text));
      expect(widget.style?.fontFamily, AppTypography.displayFont);
      expect(widget.style?.fontWeight, FontWeight.w300);
      expect(widget.style?.color, scheme.onSurface);
    }

    for (final text in ['8', 'Publicado']) {
      final widget = tester.widget<Text>(find.text(text));
      expect(widget.style?.fontFamily, AppTypography.displayFont);
      expect(widget.style?.fontWeight, FontWeight.w700);
      expect(widget.style?.color, scheme.primary);
    }
  });

  testWidgets('AdminContentNewButton usa primary, onPrimary y Begum', (
    tester,
  ) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(themed(AdminContentNewButton(onPressed: () {})));

    final label = tester.widget<Text>(find.text('Nuevo contenido'));
    expect(label.style?.fontFamily, AppTypography.displayFont);
    expect(label.style?.color, scheme.onPrimary);

    final icon = tester.widget<Icon>(find.byIcon(Icons.add_rounded));
    expect(icon.color, scheme.onPrimary);

    final buttonContainer = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration! as BoxDecoration).color == scheme.primary,
        );
    final decoration = buttonContainer.decoration! as BoxDecoration;
    expect(decoration.color, scheme.primary);
  });

  testWidgets('AdminContentFilterChip usa tokens de selección', (tester) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      themed(
        Row(
          children: [
            AdminContentFilterChip(
              label: 'Publicado',
              selected: true,
              onTap: () {},
            ),
            AdminContentFilterChip(
              label: 'Borradores',
              selected: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );

    final selectedText = tester.widget<Text>(find.text('Publicado'));
    expect(selectedText.style?.fontFamily, AppTypography.displayFont);
    expect(selectedText.style?.color, scheme.onPrimary);

    final unselectedText = tester.widget<Text>(find.text('Borradores'));
    expect(unselectedText.style?.fontFamily, AppTypography.displayFont);
    expect(unselectedText.style?.color, scheme.onSurface);

    final containers = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final selectedDecoration =
        containers.elementAt(0).decoration! as BoxDecoration;
    final unselectedDecoration =
        containers.elementAt(1).decoration! as BoxDecoration;

    expect(selectedDecoration.color, scheme.primary);
    expect(unselectedDecoration.color, scheme.surface);
  });

  testWidgets('AdminContentCard usa tokens solicitados', (tester) async {
    final scheme = AppTheme.light.colorScheme;
    final now = DateTime(2026);
    final item = AppContentItem(
      uuidContentItem: 'content-1',
      tipo: 'audio',
      titulo: 'Respirar con calma',
      status: 'published',
      destacado: true,
      descargable: false,
      orden: 1,
      createdAt: now,
      updatedAt: now,
      syncedAt: now,
    );

    await tester.pumpWidget(
      themed(
        AdminContentCard(
          item: item,
          onEdit: () {},
          onPublish: () {},
          onDraft: () {},
          onArchive: () {},
        ),
      ),
    );

    final cardContainer = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AdminContentCard),
            matching: find.byType(Container),
          )
          .first,
    );
    final cardDecoration = cardContainer.decoration! as BoxDecoration;
    expect(cardDecoration.color, scheme.surface);

    final title = tester.widget<Text>(find.text('Respirar con calma'));
    expect(title.style?.fontFamily, AppTypography.displayFont);
    expect(title.style?.color, scheme.onSurface);

    for (final label in ['Audio', 'Publicado', 'Destacado']) {
      final chip = tester.widget<Text>(find.text(label));
      expect(chip.style?.fontFamily, AppTypography.displayFont);
      expect(chip.style?.color, scheme.onSurface);
    }

    for (final iconData in [
      Icons.edit_outlined,
      Icons.drafts_outlined,
      Icons.archive_outlined,
    ]) {
      final icon = tester.widget<Icon>(find.byIcon(iconData));
      expect(icon.color, scheme.primary);
    }
  });
}
