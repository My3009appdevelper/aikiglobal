import 'package:aikiglobal/core/data/common/supabase_error_messages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('describes storage permission failures', () {
    final message = contentMediaUploadErrorMessage(
      const StorageException(
        'new row violates row-level security policy',
        statusCode: '403',
      ),
    );

    expect(message, contains('Storage'));
    expect(message, contains('bucket content'));
  });

  test('describes content media table permission failures', () {
    final message = contentMediaUploadErrorMessage(
      const PostgrestException(
        message: 'new row violates row-level security policy',
        code: '42501',
      ),
    );

    expect(message, contains('content_media'));
  });
}
