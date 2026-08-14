import 'dart:async';

import 'package:flutter/material.dart';

import '../core/data/providers/app_data_container.dart';
import '../core/data/providers/app_load_coordinator.dart';
import '../core/data/providers/app_data_scope.dart';
import '../core/notifications/notification_device_runtime_host.dart';
import '../core/notifications/notification_presentation_host.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_controller.dart';
import 'aiki_theme_host.dart';
import 'app_router.dart';

class AikiApp extends StatefulWidget {
  const AikiApp({
    super.key,
    required this.themeController,
    required this.dataContainer,
  });

  final AppThemeController themeController;
  final AppDataContainer dataContainer;

  @override
  State<AikiApp> createState() => _AikiAppState();
}

class _AikiAppState extends State<AikiApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late final VoidCallback _returnToHomeShell = _popToHomeShell;
  late final AppLifecycleListener _appLifecycleListener;
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    _appLifecycleListener = AppLifecycleListener(
      onStateChange: _handleAppLifecycleChange,
    );
    widget.dataContainer.notificationNavigationCoordinator.attachRootNavigation(
      _returnToHomeShell,
    );
  }

  void _handleAppLifecycleChange(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _wasInBackground = true;
      return;
    }

    if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      widget.dataContainer.notificationNavigationCoordinator
          .refreshPendingNavigationOnResume();
      unawaited(
        widget.dataContainer.appLoadCoordinator.syncWithRemote(
          scope: AppLoadScope.appResume,
        ),
      );
      unawaited(
        widget.dataContainer.notificationInteractionRuntime?.retryPendingOpen(),
      );
    }
  }

  @override
  void didUpdateWidget(AikiApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataContainer == widget.dataContainer) {
      return;
    }
    oldWidget.dataContainer.notificationNavigationCoordinator
        .detachRootNavigation(_returnToHomeShell);
    widget.dataContainer.notificationNavigationCoordinator.attachRootNavigation(
      _returnToHomeShell,
    );
  }

  void _popToHomeShell() {
    _navigatorKey.currentState?.popUntil(
      (route) => route.settings.name == AppRouter.home,
    );
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    widget.dataContainer.notificationNavigationCoordinator.detachRootNavigation(
      _returnToHomeShell,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final interactionRuntime =
        widget.dataContainer.notificationInteractionRuntime;
    final themedApp = AppThemeScope(
      controller: widget.themeController,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        scaffoldMessengerKey: _scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Aiki Wellness Center',
        theme: AppTheme.light,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) => AikiThemeHost(
          controller: widget.themeController,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );

    return AppDataScope(
      container: widget.dataContainer,
      child: NotificationDeviceRuntimeHost(
        runtime: widget.dataContainer.notificationDeviceRuntime,
        child: interactionRuntime == null
            ? themedApp
            : NotificationPresentationHost(
                presentations: interactionRuntime.presentations,
                scaffoldMessengerKey: _scaffoldMessengerKey,
                onOpen: interactionRuntime.openForegroundNotification,
                child: themedApp,
              ),
      ),
    );
  }
}

class AppThemeScope extends InheritedWidget {
  const AppThemeScope({
    super.key,
    required AppThemeController controller,
    required super.child,
  }) : _controller = controller;

  final AppThemeController _controller;

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope no está disponible en el árbol.');
    return scope!._controller;
  }

  @override
  bool updateShouldNotify(AppThemeScope oldWidget) {
    return _controller != oldWidget._controller;
  }
}
