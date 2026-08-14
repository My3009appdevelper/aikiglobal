import 'dart:convert';
import 'dart:io';

import 'package:aikiglobal/core/data/remote/services/manual_notification_dispatch_remote_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'requests an audience preview with the edge function contract',
    () async {
      final server = await _TestFunctionServer.start(
        statusCode: 200,
        responseBody: {
          'uuid_notification_event': 'event-1',
          'title': 'Respira con AIKI',
          'body': 'Ya puedes comenzar.',
          'category': 'general',
          'audience_type': 'all_users',
          'action_type': 'open_home',
          'action_payload': <String, dynamic>{},
          'target_profile_count': 8,
          'target_device_count': 11,
        },
      );
      addTearDown(server.close);
      final service = _service(server.baseUrl);

      final preview = await service.previewManualEvent(' event-1 ');

      expect(
        server.requestUri?.path,
        '/functions/v1/dispatch-notification-event',
      );
      expect(jsonDecode(server.requestBody!), {
        'mode': 'preview',
        'uuid_notification_event': 'event-1',
      });
      expect(preview.uuidNotificationEvent, 'event-1');
      expect(preview.title, 'Respira con AIKI');
      expect(preview.body, 'Ya puedes comenzar.');
      expect(preview.audienceType, 'all_users');
      expect(preview.actionType, 'open_home');
      expect(preview.targetProfileCount, 8);
      expect(preview.targetDeviceCount, 11);
    },
  );

  test('requests a manual dispatch and maps its acceptance', () async {
    final server = await _TestFunctionServer.start(
      statusCode: 202,
      responseBody: {
        'uuid_notification_event': 'event-1',
        'uuid_notification_dispatch': 'dispatch-1',
        'status': 'pending',
        'target_profile_count': 8,
        'target_device_count': 11,
        'reused': false,
      },
    );
    addTearDown(server.close);
    final service = _service(server.baseUrl);

    final acceptance = await service.requestManualDispatch('event-1');

    final requestBody = jsonDecode(server.requestBody!) as Map<String, dynamic>;
    expect(requestBody['mode'], 'send');
    expect(requestBody['uuid_notification_event'], 'event-1');
    expect(requestBody['request_id'], isA<String>());
    expect(acceptance.uuidNotificationEvent, 'event-1');
    expect(acceptance.uuidNotificationDispatch, 'dispatch-1');
    expect(acceptance.status, 'pending');
    expect(acceptance.targetProfileCount, 8);
    expect(acceptance.targetDeviceCount, 11);
    expect(acceptance.reused, isFalse);
  });

  test('requests a resend preserving the source dispatch', () async {
    final server = await _TestFunctionServer.start(
      statusCode: 202,
      responseBody: {
        'uuid_notification_event': 'event-1',
        'uuid_notification_dispatch': 'dispatch-2',
        'source_dispatch_uuid': 'dispatch-1',
        'status': 'pending',
        'target_profile_count': 8,
        'target_device_count': 11,
        'reused': false,
      },
    );
    addTearDown(server.close);
    final service = _service(server.baseUrl);

    final acceptance = await service.requestManualResend(
      'event-1',
      'dispatch-1',
      requestId: 'request-1',
    );
    final requestBody = jsonDecode(server.requestBody!) as Map<String, dynamic>;

    expect(requestBody['source_dispatch_uuid'], 'dispatch-1');
    expect(requestBody['request_id'], 'request-1');
    expect(acceptance.uuidNotificationDispatch, 'dispatch-2');
    expect(acceptance.sourceDispatchUuid, 'dispatch-1');
  });

  test('requests analytics for a dispatch', () async {
    final server = await _TestFunctionServer.start(
      statusCode: 200,
      responseBody: {
        'uuid_notification_dispatch': 'dispatch-1',
        'target_profile_count': 1,
        'target_device_count': 1,
        'success_device_count': 1,
        'failure_device_count': 0,
        'invalid_token_count': 0,
        'inbox_count': 1,
        'opened_count': 1,
        'read_count': 1,
        'recipients': [
          {
            'uuid_profile': 'profile-1',
            'display_name': 'Ana',
            'email': 'ana@example.com',
            'opened_at': null,
            'read_at': null,
          },
        ],
      },
    );
    addTearDown(server.close);

    final analytics = await _service(
      server.baseUrl,
    ).loadAnalytics('dispatch-1');

    expect(jsonDecode(server.requestBody!), {
      'mode': 'analytics',
      'uuid_notification_dispatch': 'dispatch-1',
    });
    expect(analytics.inboxCount, 1);
    expect(analytics.recipients.single.email, 'ana@example.com');
  });

  test('rejects a preview response without its event UUID', () async {
    final server = await _TestFunctionServer.start(
      statusCode: 200,
      responseBody: {'target_profile_count': 8, 'target_device_count': 11},
    );
    addTearDown(server.close);

    await expectLater(
      _service(server.baseUrl).previewManualEvent('event-1'),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a send response for a different event UUID', () async {
    final server = await _TestFunctionServer.start(
      statusCode: 202,
      responseBody: {
        'uuid_notification_event': 'event-2',
        'uuid_notification_dispatch': 'dispatch-1',
        'status': 'pending',
        'target_profile_count': 8,
        'target_device_count': 11,
        'reused': false,
      },
    );
    addTearDown(server.close);

    await expectLater(
      _service(server.baseUrl).requestManualDispatch('event-1'),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a successful HTTP response with an error envelope', () async {
    final server = await _TestFunctionServer.start(
      statusCode: 200,
      responseBody: {
        'error': {'message': 'No autorizado'},
      },
    );
    addTearDown(server.close);

    await expectLater(
      _service(server.baseUrl).previewManualEvent('event-1'),
      throwsA(isA<StateError>()),
    );
  });

  test('propagates edge function errors', () async {
    final server = await _TestFunctionServer.start(
      statusCode: 403,
      responseBody: {'message': 'No autorizado'},
    );
    addTearDown(server.close);
    final service = _service(server.baseUrl);

    await expectLater(
      service.previewManualEvent('event-1'),
      throwsA(isA<Exception>()),
    );
  });

  test('refreshes the session and retries when JWT is rejected', () async {
    final server = await _TestFunctionServer.startSequence([
      _TestResponse(
        statusCode: 401,
        responseBody: {
          'uuid_notification_event': 'event-1',
          'error': {'message': 'El JWT no es válido.'},
        },
      ),
      _TestResponse(
        statusCode: 200,
        responseBody: {
          'uuid_notification_event': 'event-1',
          'title': 'Respira con AIKI',
          'body': 'Ya puedes comenzar.',
          'category': 'general',
          'audience_type': 'all_users',
          'action_type': 'open_home',
          'action_payload': <String, dynamic>{},
          'target_profile_count': 1,
          'target_device_count': 1,
        },
      ),
    ]);
    addTearDown(server.close);
    var refreshCount = 0;
    final service = _service(
      server.baseUrl,
      refreshSession: () async => refreshCount++,
    );

    final preview = await service.previewManualEvent('event-1');

    expect(refreshCount, 1);
    expect(server.requestCount, 2);
    expect(preview.targetDeviceCount, 1);
  });
}

ManualNotificationDispatchRemoteService _service(
  String baseUrl, {
  Future<void> Function()? refreshSession,
}) {
  return ManualNotificationDispatchRemoteService(
    supabase: SupabaseClient(baseUrl, 'test-anon-key'),
    refreshSession: refreshSession,
  );
}

class _TestFunctionServer {
  _TestFunctionServer._({
    required HttpServer server,
    required List<_TestResponse> responses,
  }) : _server = server,
       _responses = responses {
    _server.listen(_handleRequest);
  }

  final HttpServer _server;
  final List<_TestResponse> _responses;
  int requestCount = 0;
  Uri? requestUri;
  String? requestBody;

  String get baseUrl => 'http://${_server.address.address}:${_server.port}';

  static Future<_TestFunctionServer> start({
    required int statusCode,
    required Object responseBody,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    return _TestFunctionServer._(
      server: server,
      responses: [
        _TestResponse(statusCode: statusCode, responseBody: responseBody),
      ],
    );
  }

  static Future<_TestFunctionServer> startSequence(
    List<_TestResponse> responses,
  ) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    return _TestFunctionServer._(server: server, responses: responses);
  }

  Future<void> close() => _server.close(force: true);

  Future<void> _handleRequest(HttpRequest request) async {
    requestUri = request.uri;
    requestBody = await utf8.decoder.bind(request).join();
    final response =
        _responses[requestCount < _responses.length
            ? requestCount
            : _responses.length - 1];
    requestCount++;
    request.response.statusCode = response.statusCode;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(response.responseBody));
    await request.response.close();
  }
}

class _TestResponse {
  const _TestResponse({required this.statusCode, required this.responseBody});

  final int statusCode;
  final Object responseBody;
}
