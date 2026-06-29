import 'package:aikiglobal/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a persistent label when labelText is provided', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Contenido inicial');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            controller: controller,
            hintText: 'Título',
            labelText: 'Título',
          ),
        ),
      ),
    );

    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Contenido inicial'), findsOneWidget);
  });
}
