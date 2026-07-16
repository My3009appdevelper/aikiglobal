import 'package:aikiglobal/shared/widgets/my_image_picker_permission_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  test('camera requires manual permission outside web', () {
    expect(
      imagePickerNeedsManualPermission(ImageSource.camera, isWeb: false),
      isTrue,
    );
    expect(
      imagePickerNeedsManualPermission(ImageSource.camera, isWeb: true),
      isFalse,
    );
  });

  test('gallery does not require manual permission before opening picker', () {
    expect(
      imagePickerNeedsManualPermission(ImageSource.gallery, isWeb: false),
      isFalse,
    );
  });
}
