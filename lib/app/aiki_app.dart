import 'package:flutter/material.dart';

import '../core/data/providers/app_data_container.dart';
import '../core/data/providers/app_data_scope.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_controller.dart';
import 'app_router.dart';

class AikiApp extends StatelessWidget {
  const AikiApp({
    super.key,
    required this.themeController,
    required this.dataContainer,
  });

  final AppThemeController themeController;
  final AppDataContainer dataContainer;

  @override
  Widget build(BuildContext context) {
    return AppDataScope(
      container: dataContainer,
      child: AppThemeScope(
        controller: themeController,
        child: AnimatedBuilder(
          animation: themeController,
          builder: (context, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Aiki Wellness Center',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeController.themeMode,
              initialRoute: AppRouter.splash,
              onGenerateRoute: AppRouter.onGenerateRoute,
            );
          },
        ),
      ),
    );
  }
}

class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    super.key,
    required AppThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope no está disponible en el árbol.');
    return scope!.notifier!;
  }
}
