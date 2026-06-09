import 'package:flutter/material.dart';

import '../../../app/aiki_app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/app_setting_tile.dart';

class ThemeModeTile extends StatelessWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppThemeScope.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return AppSettingTile(
          icon: Icons.wb_sunny_outlined,
          title: 'Modo de tema',
          subtitle: 'Elige entre claro u oscuro',
          trailing: _VerticalThemeSwitch(
            isDark: controller.isDark,
            onLight: () => controller.setThemeMode(ThemeMode.light),
            onDark: () => controller.setThemeMode(ThemeMode.dark),
          ),
        );
      },
    );
  }
}

class _VerticalThemeSwitch extends StatelessWidget {
  const _VerticalThemeSwitch({
    required this.isDark,
    required this.onLight,
    required this.onDark,
  });

  final bool isDark;
  final VoidCallback onLight;
  final VoidCallback onDark;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final border = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    final track = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;
    final selectedColor = Theme.of(context).colorScheme.primary;
    final selectedForeground = Theme.of(context).colorScheme.onPrimary;
    final inactiveColor = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return Container(
      width: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: track,
        borderRadius: AppRadius.full,
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeOptionButton(
            tooltip: 'Tema claro',
            selected: !isDark,
            icon: Icons.light_mode_outlined,
            selectedColor: selectedColor,
            selectedForeground: selectedForeground,
            inactiveColor: inactiveColor,
            onTap: onLight,
          ),
          const SizedBox(height: 6),
          _ThemeOptionButton(
            tooltip: 'Tema oscuro',
            selected: isDark,
            icon: Icons.dark_mode_rounded,
            selectedColor: selectedColor,
            selectedForeground: selectedForeground,
            inactiveColor: inactiveColor,
            onTap: onDark,
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionButton extends StatelessWidget {
  const _ThemeOptionButton({
    required this.tooltip,
    required this.selected,
    required this.icon,
    required this.selectedColor,
    required this.selectedForeground,
    required this.inactiveColor,
    required this.onTap,
  });

  final String tooltip;
  final bool selected;
  final IconData icon;
  final Color selectedColor;
  final Color selectedForeground;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppInteractive(
      tooltip: tooltip,
      borderRadius: AppRadius.full,
      hoverScale: 1.08,
      pressedScale: 0.9,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: selected ? selectedColor : AppColors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: selected ? selectedForeground : inactiveColor,
          size: 21,
        ),
      ),
    );
  }
}
