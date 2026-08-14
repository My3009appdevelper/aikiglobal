import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import 'app_interactive.dart';

enum AppBackButtonVariant { standard, overlay }

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    required this.onTap,
    this.tooltip = 'Regresar',
    this.size = 56,
    this.iconSize = 32,
    this.variant = AppBackButtonVariant.standard,
    this.enabled = true,
  });

  const AppBackButton.overlay({
    super.key,
    required this.onTap,
    this.tooltip = 'Regresar',
    this.size = 56,
    this.iconSize = 32,
    this.enabled = true,
  }) : variant = AppBackButtonVariant.overlay;

  final VoidCallback? onTap;
  final String tooltip;
  final double size;
  final double iconSize;
  final AppBackButtonVariant variant;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isOverlay = variant == AppBackButtonVariant.overlay;
    final background = isOverlay
        ? AppColors.black.withValues(alpha: 0.28)
        : scheme.surface;
    final foreground = isOverlay ? AppColors.white : scheme.onSurface;

    return AppInteractive(
      tooltip: tooltip,
      borderRadius: AppRadius.full,
      hoverScale: 1,
      pressedScale: 1,
      enabled: enabled,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: isOverlay ? null : AppShadows.soft(brightness),
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: foreground,
          size: iconSize,
        ),
      ),
    );
  }
}
