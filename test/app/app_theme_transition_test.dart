import 'package:aikiglobal/app/app_theme_transition.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('theme changes use a short animated transition', () {
    expect(appThemeAnimationDuration, greaterThan(Duration.zero));
    expect(
      appThemeAnimationDuration,
      lessThanOrEqualTo(const Duration(milliseconds: 300)),
    );
    expect(appThemeAnimationCurve, Curves.easeOutCubic);
  });
}
