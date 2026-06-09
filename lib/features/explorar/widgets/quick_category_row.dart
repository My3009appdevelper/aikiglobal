import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/app_category_chip.dart';

class QuickCategoryRow extends StatelessWidget {
  const QuickCategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    final primaryIconColor = brightness == Brightness.dark
        ? AppColors.sand
        : AppColors.primary;
    final secondaryIconColor = brightness == Brightness.dark
        ? AppColors.sandLight
        : AppColors.primaryDeep;
    final iconForeground = brightness == Brightness.dark
        ? AppColors.primaryDeep
        : AppColors.white;

    return Container(
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: AppCategoryChip(
              icon: Icons.graphic_eq_rounded,
              label: 'Audios',
              caption: '15 sonidos',
              color: primaryIconColor,
              foregroundColor: iconForeground,
            ),
          ),
          Expanded(
            child: AppCategoryChip(
              icon: Icons.self_improvement_rounded,
              label: 'Meditaciones',
              caption: '9 prácticas',
              color: secondaryIconColor,
              foregroundColor: iconForeground,
            ),
          ),
          Expanded(
            child: AppCategoryChip(
              icon: Icons.volunteer_activism_outlined,
              label: 'Cursos',
              caption: '8 rutas',
              color: primaryIconColor,
              foregroundColor: iconForeground,
            ),
          ),
          Expanded(
            child: AppCategoryChip(
              icon: Icons.favorite_border_rounded,
              label: 'Favoritos',
              caption: '6 guardados',
              color: secondaryIconColor,
              foregroundColor: iconForeground,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
