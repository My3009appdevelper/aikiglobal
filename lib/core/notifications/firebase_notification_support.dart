import 'package:flutter/foundation.dart';

bool supportsFirebaseNotificationRuntime({
  required bool isWeb,
  required TargetPlatform platform,
}) {
  return !isWeb && platform == TargetPlatform.android;
}
