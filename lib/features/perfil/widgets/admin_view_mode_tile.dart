import 'package:flutter/material.dart';

import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/data/providers/current_profile_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/app_setting_tile.dart';

class AdminViewModeTile extends StatelessWidget {
  const AdminViewModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = AppDataScope.currentProfile(context);
    final contentController = AppDataScope.contentItems(context);

    return AnimatedBuilder(
      animation: profileController,
      builder: (context, _) {
        if (!profileController.isAdmin) {
          return const SizedBox.shrink();
        }

        return AppSettingTile(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Vista de trabajo',
          subtitle: profileController.isAdminView
              ? 'Administrando contenido y usuarios'
              : 'Navegando como usuario',
          trailing: _AdminViewSwitch(
            mode: profileController.viewMode,
            onUser: () {
              profileController.setViewMode(AppViewMode.user);
              contentController.watchPublished();
            },
            onAdmin: () {
              profileController.setViewMode(AppViewMode.admin);
              contentController.watchAdminAll();
            },
          ),
        );
      },
    );
  }
}

class _AdminViewSwitch extends StatelessWidget {
  const _AdminViewSwitch({
    required this.mode,
    required this.onUser,
    required this.onAdmin,
  });

  final AppViewMode mode;
  final VoidCallback onUser;
  final VoidCallback onAdmin;

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
          _ModeButton(
            tooltip: 'Vista usuario',
            selected: mode == AppViewMode.user,
            icon: Icons.person_outline_rounded,
            selectedColor: selectedColor,
            selectedForeground: selectedForeground,
            inactiveColor: inactiveColor,
            onTap: onUser,
          ),
          const SizedBox(height: 6),
          _ModeButton(
            tooltip: 'Vista admin',
            selected: mode == AppViewMode.admin,
            icon: Icons.admin_panel_settings_outlined,
            selectedColor: selectedColor,
            selectedForeground: selectedForeground,
            inactiveColor: inactiveColor,
            onTap: onAdmin,
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
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
