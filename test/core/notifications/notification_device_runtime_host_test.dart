import 'package:aikiglobal/core/notifications/notification_device_runtime.dart';
import 'package:aikiglobal/core/notifications/notification_device_runtime_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('refreshes registration when the app resumes', (tester) async {
    final runtime = _RecordingNotificationDeviceLifecycle();
    await tester.pumpWidget(
      NotificationDeviceRuntimeHost(
        runtime: runtime,
        child: const MaterialApp(home: SizedBox()),
      ),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(runtime.refreshCalls, 1);
  });
}

class _RecordingNotificationDeviceLifecycle
    implements NotificationDeviceLifecycle {
  int refreshCalls = 0;

  @override
  Future<void> refreshCurrentProfile() async {
    refreshCalls++;
  }
}
