import 'package:aikiglobal/shared/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reserva altura estable para el logo completo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppLogo(width: 148))),
    );

    final image = tester.widget<Image>(find.byType(Image));

    expect(image.width, 148);
    expect(image.height, closeTo(65.5843, 0.001));
    expect(image.gaplessPlayback, isTrue);
  });

  testWidgets('reserva altura estable para el logo compacto', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppLogo(width: 40, compact: true)),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));

    expect(image.width, 40);
    expect(image.height, 40);
    expect(image.gaplessPlayback, isTrue);
  });
}
