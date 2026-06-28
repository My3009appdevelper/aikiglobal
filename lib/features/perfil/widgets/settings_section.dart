import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/app_setting_tile.dart';
import 'admin_view_mode_tile.dart';
import 'theme_mode_tile.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Container(
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: AppDataScope.currentProfile(context),
            builder: (context, _) {
              final profileController = AppDataScope.currentProfile(context);
              if (!profileController.isAdmin) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  const AdminViewModeTile(),
                  Divider(height: 1, color: stroke),
                ],
              );
            },
          ),
          AppSettingTile(
            icon: Icons.person_outline_rounded,
            title: 'Datos personales',
            subtitle: 'Gestiona tu información personal',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRouter.personalData),
          ),
          Divider(height: 1, color: stroke),
          const ThemeModeTile(),
          Divider(height: 1, color: stroke),
          const AppSettingTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notificaciones',
            subtitle: 'Gestiona tus preferencias',
          ),
          Divider(height: 1, color: stroke),
          const AppSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacidad',
            subtitle: 'Controla tu privacidad y datos',
          ),
          Divider(height: 1, color: stroke),
          AppSettingTile(
            icon: Icons.logout_rounded,
            title: 'Cerrar sesión',
            subtitle: 'Salir de tu cuenta de Aiki',
            danger: true,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
