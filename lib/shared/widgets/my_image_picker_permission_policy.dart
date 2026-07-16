import 'package:image_picker/image_picker.dart';

bool imagePickerNeedsManualPermission(
  ImageSource source, {
  required bool isWeb,
}) {
  if (isWeb) {
    return false;
  }

  return source == ImageSource.camera;
}
