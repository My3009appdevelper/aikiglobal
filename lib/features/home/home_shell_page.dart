import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/data/models/app_content_item.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/data/providers/wellness_profile_stats_controller.dart';
import '../../core/notifications/notification_navigation_controller.dart';
import '../../app/app_router.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_bottom_nav_bar.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_progress_celebration_overlay.dart';
import '../admin/admin_company_info/admin_company_info_page.dart';
import '../admin/admin_content/admin_content_page.dart';
import '../admin/admin_notifications/admin_notifications_page.dart';
import '../admin/admin_users/admin_users_page.dart';
import '../empresa/company_info_page.dart';
import '../espacio_seguro/espacio_seguro_page.dart';
import '../espacio_seguro/meditation_timer_page.dart';
import '../explorar/content_detail_page.dart';
import '../explorar/explorar_page.dart';
import '../perfil/perfil_page.dart';
import 'home_shell_navigation.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _currentIndex = 0;
  List<AppBottomNavItem>? _lastItems;
  WellnessProfileStatsController? _statsController;
  NotificationNavigationCoordinator? _notificationCoordinator;
  int? _lastHandledStreakEventId;
  bool _showStreakOverlay = false;
  AppProgressCelebrationData? _streakOverlayData;
  bool _notificationConsumptionScheduled = false;
  bool _isHandlingNotification = false;

  static const _userPages = [ExplorarPage(), EspacioSeguroPage(), PerfilPage()];

  static const _adminPages = [
    AdminContentPage(),
    AdminCompanyInfoPage(),
    AdminUsersPage(),
    AdminNotificationsPage(),
    PerfilPage(),
  ];

  static const _userItems = [
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

  static const _adminItems = [
    AppBottomNavItem(
      label: 'Contenido',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
    ),
    AppBottomNavItem(
      label: 'Empresa',
      icon: Icons.business_outlined,
      activeIcon: Icons.business_rounded,
    ),
    AppBottomNavItem(
      label: 'Usuarios',
      icon: Icons.group_outlined,
      activeIcon: Icons.group_rounded,
    ),
    AppBottomNavItem(
      label: 'Avisos',
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_rounded,
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
    if (_statsController != nextController) {
      _statsController?.removeListener(_handleStreakChange);
      _statsController = nextController;
      _statsController?.addListener(_handleStreakChange);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleStreakChange();
        }
      });
    }

    final nextNotificationCoordinator = AppDataScope.notificationNavigation(
      context,
    );
    if (_notificationCoordinator == nextNotificationCoordinator) {
      return;
    }

    _notificationCoordinator
      ?..removeListener(_scheduleNotificationConsumption)
      ..detachHomeShell();
    _notificationCoordinator = nextNotificationCoordinator
      ..attachHomeShell()
      ..addListener(_scheduleNotificationConsumption);
    _scheduleNotificationConsumption();
  }

  @override
  void dispose() {
    _statsController?.removeListener(_handleStreakChange);
    _notificationCoordinator
      ?..removeListener(_scheduleNotificationConsumption)
      ..detachHomeShell();
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

  void _scheduleNotificationConsumption() {
    if (_notificationConsumptionScheduled || _isHandlingNotification) {
      return;
    }
    _notificationConsumptionScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationConsumptionScheduled = false;
      if (mounted) {
        unawaited(_consumePendingNotification());
      }
    });
  }

  Future<void> _consumePendingNotification() async {
    if (_isHandlingNotification) {
      return;
    }
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) {
      return;
    }

    final profileController = AppDataScope.currentProfile(context);
    final profileUuid = profileController.profile?.uuidProfile;
    final coordinator = _notificationCoordinator;
    if (!profileController.isAuthenticated ||
        profileUuid == null ||
        coordinator == null ||
        coordinator.activeProfileUuid != profileUuid) {
      return;
    }

    _isHandlingNotification = true;
    final intent = coordinator.peekPendingForActiveProfile();
    if (intent == null) {
      _isHandlingNotification = false;
      return;
    }

    var handled = false;
    try {
      await _openNotificationIntent(intent);
      handled = true;
      coordinator.acknowledgePendingForActiveProfile(intent);
    } catch (_) {
      if (mounted) {
        _showNotificationMessage(
          'No se pudo abrir esta notificación. Inténtalo nuevamente.',
        );
      }
    } finally {
      _isHandlingNotification = false;
      if (handled) {
        _scheduleNotificationConsumption();
      }
    }
  }

  Future<void> _openNotificationIntent(
    NotificationNavigationIntent intent,
  ) async {
    final destination = intent.destination;
    if (destination == null || !mounted) {
      return;
    }

    switch (destination) {
      case NotificationDestination.dialog:
        await _showNotificationDialog(intent);
      case NotificationDestination.home:
      case NotificationDestination.explore:
        final index = homeIndexForNotificationDestination(destination);
        if (index != null && mounted) {
          setState(() => _currentIndex = index);
        }
      case NotificationDestination.meditation:
        final index = homeIndexForNotificationDestination(destination);
        if (index != null && mounted) {
          setState(() => _currentIndex = index);
        }
        if (mounted) {
          await Navigator.of(
            context,
          ).push(_notificationRoute(const MeditationTimerPage()));
        }
      case NotificationDestination.companyInfo:
        await Navigator.of(
          context,
        ).push(_notificationRoute(const CompanyInfoPage()));
      case NotificationDestination.contentItem:
        await _openNotificationContent(intent);
    }
  }

  Future<void> _showNotificationDialog(NotificationNavigationIntent intent) {
    final payload = intent.payload;
    final title = payload.title == null || payload.title!.trim().isEmpty
        ? 'Notificación'
        : payload.title!;
    final body = payload.body == null || payload.body!.trim().isEmpty
        ? 'Tienes una nueva notificación.'
        : payload.body!;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const AppLogo(compact: true, width: 42),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AIKI', style: Theme.of(dialogContext).textTheme.labelMedium),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
        content: Text(body, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openNotificationContent(
    NotificationNavigationIntent intent,
  ) async {
    final contentUuid =
        intent.payload.actionPayload['uuid_content_item'] as String;
    final content = await _resolvePublishedContent(contentUuid);
    if (!mounted) {
      return;
    }
    if (content == null) {
      _showNotificationMessage(
        'El contenido de esta notificación ya no está disponible.',
      );
      return;
    }

    setState(() => _currentIndex = 0);
    await Navigator.of(context).push(
      _notificationRoute(
        ContentDetailPage(item: notificationContentItemForDetail(content)),
      ),
    );
  }

  Future<AppContentItem?> _resolvePublishedContent(
    String uuidContentItem,
  ) async {
    final controller = AppDataScope.contentItems(context);
    var item = _publishedContentByUuid(
      await controller.getPublishedSnapshot(),
      uuidContentItem,
    );
    if (item != null) {
      return item;
    }

    await controller.pullFromRemote();
    if (!mounted) {
      return null;
    }
    item = _publishedContentByUuid(
      await controller.getPublishedSnapshot(),
      uuidContentItem,
    );
    return item;
  }

  void _showNotificationMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppDataScope.currentProfile(context),
      builder: (context, _) {
        final profileController = AppDataScope.currentProfile(context);
        final isAuthenticated = profileController.isAuthenticated;
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

        final isAdminView = profileController.isAdminView;
        final pages = isAdminView ? _adminPages : _userPages;
        final items = isAdminView ? _adminItems : _userItems;
        final safeIndex = resolveHomeShellIndex(
          currentIndex: _currentIndex,
          currentItems: _lastItems ?? items,
          nextItems: items,
        );
        _currentIndex = safeIndex;
        _lastItems = items;

        return Scaffold(
          body: AppBackground(
            animateEntry: true,
            entryDuration: const Duration(milliseconds: 3000),
            contentDelay: const Duration(milliseconds: 2000),
            imageAsset: AppAssets.backgroundGarden,
            imageOpacity: 0.045,
            child: Stack(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  opacity: _showStreakOverlay ? 0 : 1,
                  child: IgnorePointer(
                    ignoring: _showStreakOverlay,
                    child: Stack(
                      children: [
                        IndexedStack(index: safeIndex, children: pages),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: AppBottomNavBar(
                              items: items,
                              currentIndex: safeIndex,
                              onTap: (index) {
                                if (index != safeIndex) {
                                  final coordinator =
                                      AppDataScope.loadCoordinator(context);
                                  unawaited(
                                    isAdminView
                                        ? coordinator.syncForAdminTab(index)
                                        : coordinator.syncForUserTab(index),
                                  );
                                }
                                setState(() => _currentIndex = index);
                              },
                            ),
                          ),
                        ),
                      ],
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
          ),
        );
      },
    );
  }
}

Route<void> _notificationRoute(Widget page) {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 520),
    reverseTransitionDuration: const Duration(milliseconds: 360),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.025),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}

AppProgressCelebrationData _streakCelebrationData(
  WellnessStreakChangeEvent event,
) {
  return switch (event.type) {
    WellnessStreakChangeType.increased => AppProgressCelebrationData(
      title: 'Progreso actualizado',
      body: 'Ya llevas ${_streakDaysLabel(event.streak)} cuidando de ti.',
      icon: Icons.local_fire_department_rounded,
      fromValue: event.previousStreak,
      toValue: event.streak,
      valueLabel: 'días',
    ),
    WellnessStreakChangeType.reset => AppProgressCelebrationData(
      title: 'Tu progreso vuelve a empezar',
      body: 'Hoy puedes retomarla con calma, un paso a la vez.',
      icon: Icons.spa_rounded,
      fromValue: event.previousStreak,
      toValue: event.streak,
      valueLabel: 'días',
    ),
  };
}

String _streakDaysLabel(int days) {
  return days == 1 ? '1 día de progreso' : '$days días de progreso';
}

AppContentItem? _publishedContentByUuid(
  List<AppContentItem> items,
  String uuidContentItem,
) {
  final cleanUuid = uuidContentItem.trim();
  for (final item in items) {
    if (item.uuidContentItem == cleanUuid && item.isPublished) {
      return item;
    }
  }
  return null;
}
