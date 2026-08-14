import 'dart:async';

import 'package:flutter/widgets.dart';

import 'notification_device_runtime.dart';

class NotificationDeviceRuntimeHost extends StatefulWidget {
  const NotificationDeviceRuntimeHost({
    super.key,
    required this.runtime,
    required this.child,
  });

  final NotificationDeviceLifecycle? runtime;
  final Widget child;

  @override
  State<NotificationDeviceRuntimeHost> createState() =>
      _NotificationDeviceRuntimeHostState();
}

class _NotificationDeviceRuntimeHostState
    extends State<NotificationDeviceRuntimeHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.runtime?.refreshCurrentProfile());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
