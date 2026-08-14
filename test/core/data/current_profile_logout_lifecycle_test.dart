import 'package:aikiglobal/core/data/providers/current_profile_controller.dart';
import 'package:aikiglobal/core/data/remote/services/auth_remote_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('deactivates the device before signing out from Supabase', () async {
    final events = <String>[];
    final authService = _RecordingAuthRemoteService(events);
    final controller = CurrentProfileController(
      profilesDao: null,
      remoteService: null,
      syncService: null,
      authService: authService,
      beforeSignOut: () async {
        events.add('deactivate-device');
      },
    );
    addTearDown(controller.dispose);

    await controller.signOut();

    expect(events, ['deactivate-device', 'remote-sign-out']);
  });

  test('does not sign out when device deactivation fails', () async {
    final events = <String>[];
    final authService = _RecordingAuthRemoteService(events);
    final controller = CurrentProfileController(
      profilesDao: null,
      remoteService: null,
      syncService: null,
      authService: authService,
      beforeSignOut: () async {
        events.add('deactivate-device');
        throw StateError('No se pudo desactivar el dispositivo.');
      },
    );
    addTearDown(controller.dispose);

    await expectLater(controller.signOut(), throwsStateError);

    expect(events, ['deactivate-device']);
  });
}

class _RecordingAuthRemoteService extends AuthRemoteService {
  _RecordingAuthRemoteService(this.events)
    : super(
        supabase: SupabaseClient(
          'https://example.supabase.co',
          'test-anon-key',
        ),
      );

  final List<String> events;

  @override
  Future<void> signOut() async {
    events.add('remote-sign-out');
  }
}
