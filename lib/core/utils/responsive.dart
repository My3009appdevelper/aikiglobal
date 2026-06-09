import 'dart:math' as math;

import 'package:flutter/material.dart';

class Responsive {
  const Responsive._();

  static bool isWide(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 700;
  }

  static double appWidth(BuildContext context, {double maxWidth = 520}) {
    final width = MediaQuery.sizeOf(context).width;
    return math.min(width, maxWidth);
  }
}
