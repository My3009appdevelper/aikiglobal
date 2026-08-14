import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/data/providers/app_load_coordinator.dart';
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
    await AppDataScope.loadCoordinator(
      context,
    ).syncWithRemote(scope: AppLoadScope.safeSpace);
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
    final scheme = Theme.of(context).colorScheme;

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
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: scheme.onSurface,
                  fontFamily: AppTypography.displayFont,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Este es tu lugar para volver a ti.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
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
    final scheme = Theme.of(context).colorScheme;
    final inboxController = AppDataScope.notificationsInbox(context);

    return AnimatedBuilder(
      animation: inboxController,
      builder: (context, _) => AppInteractive(
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
            color: scheme.primary,
            shape: BoxShape.circle,
            boxShadow: AppShadows.soft(brightness),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: scheme.onPrimary,
                ),
              ),
              if (inboxController.unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: scheme.onPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.primary, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
