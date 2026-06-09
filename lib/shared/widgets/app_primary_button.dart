import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import 'app_interactive.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.expand = true,
    this.height = 62,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final foreground = scheme.onPrimary;
    final content = AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.55,
      child: AppInteractive(
        tooltip: enabled ? label : null,
        borderRadius: AppRadius.full,
        hoverScale: expand ? 1.01 : 1.03,
        onTap: onPressed,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          decoration: BoxDecoration(
            borderRadius: AppRadius.full,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [scheme.primary, scheme.secondary],
            ),
            boxShadow: AppShadows.soft(brightness),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontSize: 18,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 14),
                Icon(icon, color: foreground, size: 25),
              ],
            ],
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: content) : content;
  }
}
