import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_responsive_container.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        imageAsset: AppAssets.backgroundGarden,
        imageOpacity: 0.04,
        child: SafeArea(
          child: AppResponsiveContainer(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Regresar',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const Spacer(),
                          const AppLogo(width: 148),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Notificaciones',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mantente al día con tu bienestar.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _NotificationTile(
                        icon: Icons.local_florist_outlined,
                        title: 'Nuevo curso disponible',
                        body:
                            'Descubre “Conecta con la tierra” y transforma tu energía.',
                        time: 'Hoy, 8:30 a.m.',
                        image: AppAssets.curso2,
                      ),
                      const _NotificationTile(
                        icon: Icons.self_improvement_rounded,
                        title: 'Nueva meditación guiada',
                        body: 'Paciencia y tiempo divino ya está disponible.',
                        time: 'Ayer, 7:15 p.m.',
                        image: AppAssets.meditacion2,
                      ),
                      const _NotificationTile(
                        icon: Icons.calendar_month_outlined,
                        title: 'Tu próxima clase es hoy',
                        body: 'Yoga master class comienza a las 8:00 a.m.',
                        time: 'Hoy, 7:00 a.m.',
                        image: AppAssets.curso8,
                      ),
                      const _NotificationTile(
                        icon: Icons.favorite_border_rounded,
                        title: 'Recordatorio amable',
                        body:
                            'Dile sí a tu paz interior. Tómate un momento para ti.',
                        time: 'Ayer, 9:00 a.m.',
                        image: AppAssets.audio15,
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.image,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final String image;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    final accent = Theme.of(context).colorScheme.primary;
    final accentForeground = Theme.of(context).colorScheme.onPrimary;

    return AppInteractive(
      tooltip: 'Abrir notificación',
      borderRadius: AppRadius.large,
      hoverScale: 1.012,
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.large,
          border: Border.all(color: stroke),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: accent,
                child: Icon(icon, color: accentForeground, size: 22),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 44),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          time,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: AppRadius.small,
                  child: Image.asset(
                    image,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
