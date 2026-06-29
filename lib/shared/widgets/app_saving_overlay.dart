import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

class AppSavingOverlay extends StatelessWidget {
  const AppSavingOverlay({
    super.key,
    required this.isSaving,
    required this.child,
    this.message = 'Guardando cambios...',
    this.detail = 'Por favor espera un momento.',
  });

  final bool isSaving;
  final Widget child;
  final String message;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isSaving,
      child: Stack(
        children: [
          child,
          if (isSaving)
            Positioned.fill(
              child: _SavingBarrier(message: message, detail: detail),
            ),
        ],
      ),
    );
  }
}

class _SavingBarrier extends StatelessWidget {
  const _SavingBarrier({required this.message, required this.detail});

  final String message;
  final String? detail;

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

    return AbsorbPointer(
      child: ColoredBox(
        color: AppColors.primaryDeep.withValues(
          alpha: brightness == Brightness.dark ? 0.68 : 0.36,
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Semantics(
              label: message,
              liveRegion: true,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 310),
                margin: const EdgeInsets.all(AppSpacing.lg),
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                decoration: BoxDecoration(
                  color: surface.withValues(alpha: 0.96),
                  borderRadius: AppRadius.large,
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.22),
                  ),
                  boxShadow: AppShadows.elevated(brightness),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 78,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 4,
                            strokeCap: StrokeCap.round,
                            color: scheme.primary,
                            backgroundColor: scheme.primary.withValues(
                              alpha: 0.12,
                            ),
                          ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.self_improvement_rounded,
                              color: scheme.primary,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (detail != null && detail!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        detail!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: muted,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
