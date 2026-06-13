import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_responsive_container.dart';
import 'widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cardColor = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackground(
        animateEntry: true,
        entryDuration: const Duration(milliseconds: 3000),
        contentDelay: const Duration(milliseconds: 1000),
        imageAsset: AppAssets.backgroundArchitecture,
        imageOpacity: 0.12,
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: AppResponsiveContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 256,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: AppRadius.extraLarge,
                                child: Image.asset(
                                  AppAssets.backgroundArchitecture,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.sandLight,
                                            AppColors.sand,
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: AppRadius.extraLarge,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.ivory.withValues(alpha: 0.18),
                                      AppColors.ivory.withValues(alpha: 0.82),
                                    ],
                                  ),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(28),
                                  child: AppLogo(width: 230),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -26),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
                            decoration: BoxDecoration(
                              color: cardColor.withValues(alpha: 0.92),
                              borderRadius: AppRadius.extraLarge,
                              border: Border.all(
                                color: brightness == Brightness.dark
                                    ? AppColors.darkStroke
                                    : AppColors.stroke,
                              ),
                              boxShadow: AppShadows.elevated(brightness),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Crear cuenta',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Comienza tu camino de paz, claridad y bienestar.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 22),
                                const RegisterForm(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
