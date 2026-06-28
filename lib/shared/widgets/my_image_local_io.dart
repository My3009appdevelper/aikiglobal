import 'dart:io';

import 'package:flutter/widgets.dart';

Widget buildLocalImage({
  required String path,
  required BoxFit fit,
  required Widget fallback,
}) {
  final file = File(_cleanLocalPath(path));
  if (!file.existsSync()) {
    return fallback;
  }

  return Image.file(file, fit: fit, errorBuilder: (_, _, _) => fallback);
}

String _cleanLocalPath(String value) {
  final uri = Uri.tryParse(value);
  if (uri != null && uri.scheme == 'file') {
    return uri.toFilePath();
  }

  return value;
}
