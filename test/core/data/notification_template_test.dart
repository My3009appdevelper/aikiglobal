import 'package:aikiglobal/core/data/models/notification_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes template parts while preserving token positions', () {
    final parts = parseNotificationTemplate(
      'Hola {profile_name}, descubre {content_title}.',
      allowedVariables: const {'profile_name', 'content_title'},
    );

    expect(
      serializeNotificationTemplate(parts),
      'Hola {profile_name}, descubre {content_title}.',
    );
    expect(
      renderNotificationTemplateExample(
        parts,
        examples: const {
          'profile_name': 'Ana',
          'content_title': 'Respiración consciente',
        },
      ),
      'Hola Ana, descubre Respiración consciente.',
    );
  });

  test('keeps unknown template variables as text for safe editing', () {
    final parts = parseNotificationTemplate(
      'Mensaje {unknown_variable}',
      allowedVariables: const {'profile_name'},
    );

    expect(serializeNotificationTemplate(parts), 'Mensaje {unknown_variable}');
    expect(parts.where((part) => part.isToken), isEmpty);
  });
}
