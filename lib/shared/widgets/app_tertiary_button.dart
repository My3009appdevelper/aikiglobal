import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import 'app_interactive.dart';

class AppTertiaryButton extends StatelessWidget {
  const AppTertiaryButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.tooltip,
    this.expand = false,
    this.height = 40,
  }) : assert(label != null || icon != null);

  final String? label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? tooltip;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final enabled = onPressed != null;
    final hasLabel = label?.trim().isNotEmpty ?? false;
    final scheme = Theme.of(context).colorScheme;
    final background = scheme.primary;
    final borderColor = scheme.primary;
    final foreground = enabled
        ? scheme.onPrimary
        : (brightness == Brightness.dark
              ? AppColors.darkTextMuted
              : AppColors.textMuted);

    final content = AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.58,
      child: AppInteractive(
        tooltip: enabled ? (tooltip ?? label) : null,
        borderRadius: AppRadius.full,
        hoverScale: expand ? 1.01 : 1.03,
        pressedScale: 0.95,
        onTap: onPressed,
        child: Container(
          height: height,
          width: !expand && !hasLabel ? height : null,
          padding: EdgeInsets.symmetric(horizontal: hasLabel ? 18 : 0),
          decoration: BoxDecoration(
            color: enabled
                ? background.withValues(alpha: 0.94)
                : background.withValues(alpha: 0.18),
            borderRadius: AppRadius.full,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: 18, color: foreground),
              if (icon != null && hasLabel) ...[const SizedBox(width: 8)],
              if (hasLabel)
                Flexible(
                  child: Text(
                    label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: content) : content;
  }
}
