import 'package:aikiglobal/core/data/remote/services/content_media_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses file upload only for video content types', () {
    expect(contentMediaShouldUseFileUpload('video/mp4'), isTrue);
    expect(contentMediaShouldUseFileUpload('video/quicktime'), isTrue);
    expect(contentMediaShouldUseFileUpload('audio/mpeg'), isFalse);
    expect(contentMediaShouldUseFileUpload('audio/mp4'), isFalse);
  });
}
