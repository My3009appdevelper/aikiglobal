import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app_data_container.dart';
import 'admin_profiles_controller.dart';
import 'content_media_controller.dart';
import 'content_items_controller.dart';
import 'current_profile_controller.dart';
import 'user_content_states_controller.dart';
import 'wellness_daily_logs_controller.dart';
import 'wellness_profile_stats_controller.dart';

class AppDataScope extends StatefulWidget {
  const AppDataScope({super.key, required this.container, required this.child});

  final AppDataContainer container;
  final Widget child;

  static AppDataContainer of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_AppDataInherited>();
    assert(scope != null, 'AppDataScope no esta disponible en el arbol.');
    return scope!.container;
  }

  static CurrentProfileController currentProfile(BuildContext context) {
    return of(context).currentProfileController;
  }

  static AdminProfilesController adminProfiles(BuildContext context) {
    return of(context).adminProfilesController;
  }

  static ContentItemsController contentItems(BuildContext context) {
    return of(context).contentItemsController;
  }

  static ContentMediaController contentMedia(BuildContext context) {
    return of(context).contentMediaController;
  }

  static UserContentStatesController userContentStates(BuildContext context) {
    return of(context).userContentStatesController;
  }

  static WellnessDailyLogsController wellnessDailyLogs(BuildContext context) {
    return of(context).wellnessDailyLogsController;
  }

  static WellnessProfileStatsController wellnessProfileStats(
    BuildContext context,
  ) {
    return of(context).wellnessProfileStatsController;
  }

  @override
  State<AppDataScope> createState() => _AppDataScopeState();
}

class _AppDataScopeState extends State<AppDataScope> {
  @override
  void dispose() {
    unawaited(widget.container.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppDataInherited(container: widget.container, child: widget.child);
  }
}

class _AppDataInherited extends InheritedWidget {
  const _AppDataInherited({required this.container, required super.child});

  final AppDataContainer container;

  @override
  bool updateShouldNotify(_AppDataInherited oldWidget) {
    return container != oldWidget.container;
  }
}
