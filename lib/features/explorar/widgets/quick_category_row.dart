import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/app_category_chip.dart';

enum QuickCategoryType { meditations, audios, sounds, favorites }

class QuickCategoryRow extends StatelessWidget {
  const QuickCategoryRow({
    super.key,
    required this.meditationCount,
    required this.audioCount,
    required this.soundCount,
    required this.favoriteCount,
    this.selectedType,
    this.onSelected,
  });

  final int meditationCount;
  final int audioCount;
  final int soundCount;
  final int favoriteCount;
  final QuickCategoryType? selectedType;
  final ValueChanged<QuickCategoryType>? onSelected;

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
              icon: Icons.self_improvement_rounded,
              label: 'Meditaciones',
              caption: _countLabel(meditationCount, 'práctica', 'prácticas'),
              color: _chipColor(
                QuickCategoryType.meditations,
                primaryIconColor,
                secondaryIconColor,
              ),
              foregroundColor: iconForeground,
              onTap: () => onSelected?.call(QuickCategoryType.meditations),
            ),
          ),
          Expanded(
            child: AppCategoryChip(
              icon: Icons.headphones_rounded,
              label: 'Audios',
              caption: _countLabel(audioCount, 'audio', 'audios'),
              color: _chipColor(
                QuickCategoryType.audios,
                secondaryIconColor,
                primaryIconColor,
              ),
              foregroundColor: iconForeground,
              onTap: () => onSelected?.call(QuickCategoryType.audios),
            ),
          ),
          Expanded(
            child: AppCategoryChip(
              icon: Icons.graphic_eq_rounded,
              label: 'Sonidos',
              caption: _countLabel(soundCount, 'sonido', 'sonidos'),
              color: _chipColor(
                QuickCategoryType.sounds,
                primaryIconColor,
                secondaryIconColor,
              ),
              foregroundColor: iconForeground,
              onTap: () => onSelected?.call(QuickCategoryType.sounds),
            ),
          ),
          Expanded(
            child: AppCategoryChip(
              icon: Icons.bookmark_border_rounded,
              label: 'Favoritos',
              caption: _countLabel(favoriteCount, 'guardado', 'guardados'),
              color: _chipColor(
                QuickCategoryType.favorites,
                secondaryIconColor,
                primaryIconColor,
              ),
              foregroundColor: iconForeground,
              onTap: () => onSelected?.call(QuickCategoryType.favorites),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Color _chipColor(
    QuickCategoryType type,
    Color selectedColor,
    Color idleColor,
  ) {
    return selectedType == type ? selectedColor : idleColor;
  }

  String _countLabel(int count, String singular, String plural) {
    final label = count == 1 ? singular : plural;
    return '$count $label';
  }
}
