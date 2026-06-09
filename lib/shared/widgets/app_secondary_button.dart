import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import 'app_interactive.dart';

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.icon,
    this.expand = true,
    this.height = 58,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final IconData? icon;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final borderColor = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    final background = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;

    final enabled = onPressed != null;
    final content = AppInteractive(
      tooltip: enabled ? label : null,
      borderRadius: AppRadius.full,
      hoverScale: expand ? 1.01 : 1.03,
      onTap: onPressed,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: background.withValues(alpha: 0.8),
          borderRadius: AppRadius.full,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 10),
              Icon(icon, size: 22),
            ],
          ],
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: content) : content;
  }
}
