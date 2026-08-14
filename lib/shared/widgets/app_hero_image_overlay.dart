import 'package:flutter/material.dart';

/// Capa uniforme de surface para mejorar la lectura sobre una imagen.
class AppHeroImageOverlay extends StatelessWidget {
  const AppHeroImageOverlay({super.key, this.opacity = 0.75});

  /// 0.0 deja la imagen visible; 1.0 la cubre por completo.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return ColoredBox(color: surface.withValues(alpha: opacity));
  }
}
