import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app_data_container.dart';
import 'content_items_controller.dart';
import 'current_profile_controller.dart';

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

  static ContentItemsController contentItems(BuildContext context) {
    return of(context).contentItemsController;
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
