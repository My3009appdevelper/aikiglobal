import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import '../../shared/widgets/app_responsive_container.dart';
import '../notificaciones/notifications_page.dart';
import 'widgets/calendar_preview_card.dart';
import 'widgets/daily_streak_card.dart';
import 'widgets/meditation_today_card.dart';
import 'widgets/meditation_timer_card.dart';
import 'widgets/weekly_wellness_timeline_card.dart';

bool get _showCalendarPreviewCard => false;
bool get _showMeditationTodayCard => false;

class EspacioSeguroPage extends StatelessWidget {
  const EspacioSeguroPage({super.key});

  Future<void> _refreshSafeSpace(BuildContext context) async {
    final profile = AppDataScope.currentProfile(context).profile;
    if (profile == null) {
      return;
    }

    await Future.wait([
      AppDataScope.wellnessDailyLogs(
        context,
      ).syncWithRemote(uuidProfile: profile.uuidProfile),
      AppDataScope.wellnessProfileStats(
        context,
      ).syncWithRemote(uuidProfile: profile.uuidProfile),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AppResponsiveContainer(
        child: AppRefreshIndicator(
          onRefresh: () => _refreshSafeSpace(context),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    const AppLogo(width: 148),
                    const SizedBox(height: AppSpacing.lg),
                    const _SafeSpaceIntro(),
                    const SizedBox(height: AppSpacing.lg),
                    const DailyStreakCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const MeditationTimerCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const WeeklyWellnessTimelineCard(),
                    if (_showCalendarPreviewCard) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const CalendarPreviewCard(),
                    ],
                    if (_showMeditationTodayCard) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const MeditationTodayCard(),
                    ],
                    const SizedBox(height: 130),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SafeSpaceIntro extends StatelessWidget {
  const _SafeSpaceIntro();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final titleColor = Theme.of(context).colorScheme.onSurface;
    final bodyColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, Mau',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.displayMedium?.copyWith(color: titleColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Este es tu lugar para volver a ti.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: bodyColor),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _NotificationButton(brightness: brightness),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.white.withValues(alpha: 0.86);
    final iconColor = Theme.of(context).colorScheme.primary;

    return AppInteractive(
      tooltip: 'Ver notificaciones',
      borderRadius: AppRadius.full,
      hoverScale: 1.08,
      pressedScale: 0.9,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NotificationsPage()),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.soft(brightness),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(Icons.notifications_none_rounded, color: iconColor),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFF718456),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
