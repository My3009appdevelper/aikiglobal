import 'package:aikiglobal/shared/widgets/app_saving_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows saving overlay above its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppSavingOverlay(isSaving: true, child: Text('Formulario')),
      ),
    );

    expect(find.text('Formulario'), findsOneWidget);
    expect(find.text('Guardando cambios...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('hides saving overlay when inactive', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppSavingOverlay(isSaving: false, child: Text('Formulario')),
      ),
    );

    expect(find.text('Formulario'), findsOneWidget);
    expect(find.text('Guardando cambios...'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
