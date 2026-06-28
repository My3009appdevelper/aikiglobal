import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/data/providers/wellness_profile_stats_controller.dart';
import '../../app/app_router.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_bottom_nav_bar.dart';
import '../../shared/widgets/app_progress_celebration_overlay.dart';
import '../espacio_seguro/espacio_seguro_page.dart';
import '../explorar/explorar_page.dart';
import '../perfil/perfil_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _currentIndex = 0;
  WellnessProfileStatsController? _statsController;
  int? _lastHandledStreakEventId;
  bool _showStreakOverlay = false;
  AppProgressCelebrationData? _streakOverlayData;

  static const _pages = [ExplorarPage(), EspacioSeguroPage(), PerfilPage()];

  static const _items = [
    AppBottomNavItem(
      label: 'Explorar',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
    ),
    AppBottomNavItem(
      label: 'Mi espacio',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    AppBottomNavItem(
      label: 'Perfil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final nextController = AppDataScope.wellnessProfileStats(context);
    if (_statsController == nextController) {
      return;
    }

    _statsController?.removeListener(_handleStreakChange);
    _statsController = nextController;
    _statsController?.addListener(_handleStreakChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleStreakChange();
      }
    });
  }

  @override
  void dispose() {
    _statsController?.removeListener(_handleStreakChange);
    super.dispose();
  }

  void _handleStreakChange() {
    final event = _statsController?.lastStreakChangeEvent;
    if (event == null || event.id == _lastHandledStreakEventId) {
      return;
    }

    _lastHandledStreakEventId = event.id;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      return;
    }

    _showStreakCelebration(_streakCelebrationData(event));
  }

  void _showStreakCelebration(AppProgressCelebrationData data) {
    setState(() {
      _streakOverlayData = data;
      _showStreakOverlay = true;
    });
  }

  void _closeStreakCelebration() {
    setState(() => _showStreakOverlay = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppDataScope.currentProfile(context),
      builder: (context, _) {
        final isAuthenticated = AppDataScope.currentProfile(
          context,
        ).isAuthenticated;
        if (!isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
            }
          });

          return const Scaffold(body: SizedBox.shrink());
        }

        return Scaffold(
          body: Stack(
            children: [
              AppBackground(
                animateEntry: true,
                entryDuration: const Duration(milliseconds: 3000),
                contentDelay: const Duration(milliseconds: 2000),
                imageAsset: AppAssets.backgroundGarden,
                imageOpacity: 0.045,
                child: IndexedStack(index: _currentIndex, children: _pages),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: AppBottomNavBar(
                    items: _items,
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() => _currentIndex = index);
                    },
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_showStreakOverlay,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final scale = Tween<double>(
                        begin: 0.96,
                        end: 1,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: scale, child: child),
                      );
                    },
                    child: _showStreakOverlay
                        ? AppProgressCelebrationOverlay(
                            key: ValueKey(_streakOverlayData),
                            data: _streakOverlayData!,
                            onClose: _closeStreakCelebration,
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

AppProgressCelebrationData _streakCelebrationData(
  WellnessStreakChangeEvent event,
) {
  return switch (event.type) {
    WellnessStreakChangeType.increased => AppProgressCelebrationData(
      title: 'Racha actualizada',
      body: 'Ya llevas ${_streakDaysLabel(event.streak)} cuidando de ti.',
      icon: Icons.local_fire_department_rounded,
      fromValue: event.previousStreak,
      toValue: event.streak,
      valueLabel: 'días',
    ),
    WellnessStreakChangeType.reset => AppProgressCelebrationData(
      title: 'Tu racha vuelve a empezar',
      body: 'Hoy puedes retomarla con calma, un paso a la vez.',
      icon: Icons.spa_rounded,
      fromValue: event.previousStreak,
      toValue: event.streak,
      valueLabel: 'días',
    ),
  };
}

String _streakDaysLabel(int days) {
  return days == 1 ? '1 día seguido' : '$days días seguidos';
}
