import 'package:aikiglobal/features/explorar/widgets/quick_category_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the explore quick filters requested for users', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QuickCategoryRow(
            meditationCount: 2,
            audioCount: 3,
            soundCount: 4,
            favoriteCount: 5,
          ),
        ),
      ),
    );

    expect(find.text('Meditaciones'), findsOneWidget);
    expect(find.text('Audios'), findsOneWidget);
    expect(find.text('Sonidos'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Cursos'), findsNothing);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
  });
}
