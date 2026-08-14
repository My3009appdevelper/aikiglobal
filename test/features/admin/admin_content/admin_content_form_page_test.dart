import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/core/theme/app_typography.dart';
import 'package:aikiglobal/core/data/models/pending_content_media_upload.dart';
import 'package:aikiglobal/features/admin/admin_content/admin_content_form_page.dart';
import 'package:aikiglobal/features/admin/admin_content/content_media_form_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget themed(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  BoxDecoration decorationForFirstContainer(
    WidgetTester tester,
    Finder widgetFinder,
  ) {
    final container = tester.widget<Container>(
      find.descendant(of: widgetFinder, matching: find.byType(Container)).first,
    );
    return container.decoration! as BoxDecoration;
  }

  testWidgets('AdminContentFormCard usa surface y onSurface', (tester) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      themed(const AdminContentFormCard(child: Text('Datos principales'))),
    );

    final decoration = decorationForFirstContainer(
      tester,
      find.byType(AdminContentFormCard),
    );
    expect(decoration.color, scheme.surface);

    final textContext = tester.element(find.text('Datos principales'));
    expect(DefaultTextStyle.of(textContext).style.color, scheme.onSurface);
  });

  testWidgets('AdminContentSwitchRow usa textos onSurface', (tester) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      themed(
        AdminContentFormCard(
          child: AdminContentSwitchRow(
            title: 'Destacado',
            subtitle: 'Puede aparecer en espacios recomendados.',
            value: true,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text('Destacado'));
    expect(title.style?.color, scheme.onSurface);

    final subtitle = tester.widget<Text>(
      find.text('Puede aparecer en espacios recomendados.'),
    );
    expect(subtitle.style?.color, scheme.onSurface);
  });

  testWidgets('AdminContentTypeSelector usa el carrusel horizontal de tipos', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(AdminContentTypeSelector(value: 'course', onChanged: (_) {})),
    );

    final carousel = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('notification-options-carousel')),
    );

    expect(carousel.scrollDirection, Axis.horizontal);
    expect(find.text('Curso'), findsOneWidget);
    expect(find.byIcon(Icons.school_outlined), findsOneWidget);
    expect(find.text('Meditación'), findsOneWidget);
    expect(find.text('Audio'), findsOneWidget);
    expect(find.text('Sonido'), findsOneWidget);
    expect(find.text('Evento'), findsOneWidget);
    expect(find.text('Sesión'), findsOneWidget);
  });

  testWidgets(
    'AdminContentMediaFilesCard usa surface/onSurface y boton Begum',
    (tester) async {
      final scheme = AppTheme.light.colorScheme;

      await tester.pumpWidget(
        themed(
          AdminContentMediaFilesCard(
            items: const [],
            pendingItems: const [],
            mediaEdits: const <String, ContentMediaMetadataEdit>{},
            metadataEditable: false,
            contentTitle: '',
            contentDurationSeconds: null,
            onAdd: () {},
            onRemove: null,
            onMediaTitleChanged: null,
            onMediaDurationChanged: null,
            onRemovePending: null,
            onPendingTitleChanged: null,
            onPendingDurationChanged: null,
          ),
        ),
      );

      final surfaceContainers = tester
          .widgetList<Container>(find.byType(Container))
          .where((container) {
            final decoration = container.decoration;
            return decoration is BoxDecoration &&
                decoration.color == scheme.surface;
          });
      expect(surfaceContainers.length, greaterThanOrEqualTo(2));

      final title = tester.widget<Text>(find.text('Archivos del contenido'));
      expect(title.style?.color, scheme.onSurface);

      final subtitle = tester.widget<Text>(
        find.text(
          'Agrega video, audio o sonido ambiental para poder publicar.',
        ),
      );
      expect(subtitle.style?.color, scheme.onSurface);

      final addLabel = tester.widget<Text>(find.text('Agregar archivo'));
      expect(addLabel.style?.fontFamily, AppTypography.displayFont);
      expect(addLabel.style?.color, scheme.onSurface);

      final addIcon = tester.widget<Icon>(
        find.byIcon(Icons.upload_file_rounded),
      );
      expect(addIcon.color, scheme.onSurface);
    },
  );

  testWidgets(
    'AdminContentMediaFilesCard mantiene filas de archivo onSurface',
    (tester) async {
      final scheme = AppTheme.dark.colorScheme;

      await tester.pumpWidget(
        themed(
          AdminContentMediaFilesCard(
            items: const [],
            pendingItems: const [
              PendingContentMediaUpload(
                uuidContentMedia: 'media-1',
                tipo: 'audio',
                titulo: 'Clase 1',
                fileName: 'clase-1.mp3',
                contentType: 'audio/mpeg',
                orden: 1,
                duracionSegundos: 600,
              ),
            ],
            mediaEdits: const <String, ContentMediaMetadataEdit>{},
            metadataEditable: false,
            contentTitle: 'Respirar',
            contentDurationSeconds: 600,
            onAdd: () {},
            onRemove: null,
            onMediaTitleChanged: null,
            onMediaDurationChanged: null,
            onRemovePending: null,
            onPendingTitleChanged: null,
            onPendingDurationChanged: null,
          ),
          theme: AppTheme.dark,
        ),
      );

      final rowTitle = tester.widget<Text>(find.text('Respirar'));
      expect(rowTitle.style?.color, scheme.onSurface);

      final rowMeta = tester.widget<Text>(
        find.textContaining('Pendiente de guardar'),
      );
      expect(rowMeta.style?.color, scheme.onSurface);
    },
  );

  testWidgets('AdminContentSaveButton usa Begum y primary/onPrimary', (
    tester,
  ) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      themed(
        AdminContentSaveButton(label: 'Guardar cambios', onPressed: () {}),
      ),
    );

    final label = tester.widget<Text>(find.text('Guardar cambios'));
    expect(label.style?.fontFamily, AppTypography.displayFont);
    expect(label.style?.color, scheme.onPrimary);

    final icon = tester.widget<Icon>(find.byIcon(Icons.check_rounded));
    expect(icon.color, scheme.onPrimary);

    final primaryContainers = tester
        .widgetList<Container>(find.byType(Container))
        .where((container) {
          final decoration = container.decoration;
          return decoration is BoxDecoration &&
              decoration.color == scheme.primary;
        });
    expect(primaryContainers.length, greaterThanOrEqualTo(1));
  });
}
