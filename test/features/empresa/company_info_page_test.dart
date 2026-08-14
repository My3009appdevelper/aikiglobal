import 'package:aikiglobal/core/data/models/app_company_info.dart';
import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/core/theme/app_typography.dart';
import 'package:aikiglobal/features/empresa/company_info_page.dart';
import 'package:aikiglobal/shared/widgets/app_cover_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra fundadores y quienes somos en pestañas separadas', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyInfoContent(
              info: _companyInfo(),
              resolveImageUrl: (_) async => null,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Fundadores'), findsOneWidget);
    expect(find.text('¿Quiénes somos?'), findsOneWidget);
    expect(find.text('Mensaje de fundadores'), findsOneWidget);
    expect(find.text('Texto de fundadores para la prueba.'), findsOneWidget);
    expect(find.text('Somos Aiki Test'), findsNothing);

    await tester.tap(find.text('¿Quiénes somos?'));
    await tester.pumpAndSettle();

    expect(find.text('Mensaje de fundadores'), findsNothing);
    expect(find.text('Texto de fundadores para la prueba.'), findsNothing);
    expect(find.text('Texto de entrada Aiki para la prueba.'), findsOneWidget);
    expect(find.text('Somos Aiki Test'), findsOneWidget);
    expect(find.text('¿Y qué significa Aiki?'), findsOneWidget);
  });

  testWidgets('muestra las imágenes de fundadores en formato cuadrado', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: CompanyInfoContent(
                info: _companyInfo(
                  founderImagePaths: const ['fundadores/1.jpg'],
                ),
                resolveImageUrl: (_) async => null,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final imageSize = tester.getSize(find.byType(AppCoverImage).first);
    expect(imageSize.width, closeTo(imageSize.height, 0.1));
  });

  testWidgets('usa primary y onPrimary en la pestaña seleccionada', (
    tester,
  ) async {
    final scheme = AppTheme.dark.colorScheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: CompanyInfoContent(
            info: _companyInfo(),
            resolveImageUrl: (_) async => null,
          ),
        ),
      ),
    );
    await tester.pump();

    final selectedTab = tester.widget<AnimatedContainer>(
      find
          .ancestor(
            of: find.text('Fundadores'),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    final decoration = selectedTab.decoration as BoxDecoration;
    final label = tester.widget<Text>(find.text('Fundadores'));

    expect(decoration.color, scheme.primary);
    expect(label.style?.color, scheme.onPrimary);
    expect(label.style?.fontFamily, AppTypography.displayFont);
  });

  testWidgets('usa onSurface en los iconos de misión visión y filosofía', (
    tester,
  ) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyInfoContent(
              info: _companyInfo(),
              resolveImageUrl: (_) async => null,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('¿Quiénes somos?'));
    await tester.pumpAndSettle();

    final sectionImages = tester.widgetList<Image>(find.byType(Image));

    expect(sectionImages.length, 3);
    expect(
      sectionImages.map((image) => image.color),
      everyElement(scheme.onSurface),
    );
  });
}

AppCompanyInfo _companyInfo({List<String> founderImagePaths = const []}) {
  return AppCompanyInfo(
    uuidCompanyInfo: 'company-test',
    slug: 'main',
    heroTitulo: 'Bienvenido a tu espacio de paz interior',
    heroSubtitulo: 'Explora, aprende y conecta contigo.',
    heroImagePath: null,
    textoEntrada: 'Texto de entrada Aiki para la prueba.',
    quienesSomos: 'Somos Aiki Test',
    significadoAiki: 'Aiki significa armonía en movimiento.',
    mision: 'Misión de prueba',
    vision: 'Visión de prueba',
    filosofia: 'Filosofía de prueba',
    mensajeFundadoresTitulo: 'Mensaje de fundadores',
    mensajeFundadoresTexto: 'Texto de fundadores para la prueba.',
    mensajeFundadoresImagePath1: founderImagePaths.elementAtOrNull(0),
    mensajeFundadoresImagePath2: founderImagePaths.elementAtOrNull(1),
    mensajeFundadoresImagePath3: founderImagePaths.elementAtOrNull(2),
    mensajeFundadoresImagePath4: founderImagePaths.elementAtOrNull(3),
    mensajeFundadoresImagePath5: founderImagePaths.elementAtOrNull(4),
    createdAt: DateTime.utc(2026, 7, 16),
    updatedAt: DateTime.utc(2026, 7, 16),
    syncedAt: DateTime.utc(2026, 7, 16),
  );
}
