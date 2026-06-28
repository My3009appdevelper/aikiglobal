import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import 'app_primary_button.dart';

class AppProgressCelebrationData {
  const AppProgressCelebrationData({
    required this.title,
    required this.body,
    required this.icon,
    this.fromValue,
    this.toValue,
    this.valueLabel,
  });

  final String title;
  final String body;
  final IconData icon;
  final int? fromValue;
  final int? toValue;
  final String? valueLabel;

  bool get hasValueTransition => fromValue != null && toValue != null;
}

class AppProgressCelebrationOverlay extends StatelessWidget {
  const AppProgressCelebrationOverlay({
    super.key,
    required this.data,
    required this.onClose,
    this.closeLabel = 'Cerrar',
  });

  final AppProgressCelebrationData data;
  final VoidCallback onClose;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final muted = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return Container(
      color: AppColors.primaryDeep.withValues(
        alpha: brightness == Brightness.dark ? 0.62 : 0.34,
      ),
      padding: const EdgeInsets.all(28),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 760),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.88 + (0.12 * value),
              child: Opacity(opacity: value.clamp(0, 1), child: child),
            );
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: surface.withValues(alpha: 0.96),
              borderRadius: AppRadius.large,
              border: Border.all(color: scheme.primary.withValues(alpha: 0.24)),
              boxShadow: AppShadows.soft(brightness),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(data.icon, color: scheme.primary, size: 40),
                ),
                if (data.hasValueTransition) ...[
                  const SizedBox(height: 18),
                  _ValueTransitionDisplay(data: data),
                ],
                const SizedBox(height: 18),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.body,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: muted, height: 1.25),
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  minHeight: 5,
                  borderRadius: AppRadius.full,
                  value: 1,
                  color: scheme.primary,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 18),
                AppPrimaryButton(
                  label: closeLabel,
                  icon: Icons.check_rounded,
                  height: 48,
                  onPressed: onClose,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueTransitionDisplay extends StatelessWidget {
  const _ValueTransitionDisplay({required this.data});

  final AppProgressCelebrationData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fromValue = data.fromValue ?? 0;
    final toValue = data.toValue ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ValuePill(value: fromValue, active: false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 620),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(10 * (1 - value), 0),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Icon(
              Icons.arrow_forward_rounded,
              color: scheme.primary,
              size: 28,
            ),
          ),
        ),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: fromValue, end: toValue),
          duration: const Duration(milliseconds: 980),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return _ValuePill(
              value: value,
              active: true,
              label: data.valueLabel,
            );
          },
        ),
      ],
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.value, required this.active, this.label});

  final int value;
  final bool active;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final background = active
        ? scheme.primary
        : brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;
    final foreground = active ? scheme.onPrimary : scheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: active ? 100 : 76,
      height: active ? 96 : 76,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.large,
        border: Border.all(
          color: active
              ? scheme.primary
              : scheme.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: Text(
              '$value',
              key: ValueKey(value),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: foreground,
                fontSize: active ? 42 : 32,
                fontWeight: FontWeight.w900,
                height: 0.96,
              ),
            ),
          ),
          if (label != null && active) ...[
            const SizedBox(height: 4),
            Text(
              label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground.withValues(alpha: 0.86),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
