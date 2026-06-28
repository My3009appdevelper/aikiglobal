import 'package:aikiglobal/features/admin/admin_content/content_media_duration_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats seconds as editable minute text', () {
    expect(contentMediaDurationSecondsToMinutesText(null), '');
    expect(contentMediaDurationSecondsToMinutesText(120), '2');
    expect(contentMediaDurationSecondsToMinutesText(90), '1.5');
    expect(contentMediaDurationSecondsToMinutesText(75), '1.25');
  });

  test('parses editable minute text as seconds', () {
    expect(contentMediaDurationMinutesTextToSeconds(''), isNull);
    expect(contentMediaDurationMinutesTextToSeconds('2'), 120);
    expect(contentMediaDurationMinutesTextToSeconds('1.5'), 90);
    expect(contentMediaDurationMinutesTextToSeconds('1,25'), 75);
    expect(contentMediaDurationMinutesTextToSeconds('0'), isNull);
    expect(contentMediaDurationMinutesTextToSeconds('abc'), isNull);
  });
}
