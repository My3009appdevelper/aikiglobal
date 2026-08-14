import 'dart:math' as math;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/manual_notification_dispatch_result.dart';
import '../../models/notification_dispatch_analytics.dart';

class ManualNotificationDispatchRemoteService {
  ManualNotificationDispatchRemoteService({
    required SupabaseClient supabase,
    Future<void> Function()? refreshSession,
  }) : _supabase = supabase,
       _refreshSession =
           refreshSession ??
           (() async {
             await supabase.auth.refreshSession();
           });

  static const _functionName = 'dispatch-notification-event';

  final SupabaseClient _supabase;
  final Future<void> Function() _refreshSession;

  Future<ManualNotificationAudiencePreview> previewManualEvent(
    String uuidNotificationEvent,
  ) async {
    final cleanUuid = _requiredEventUuid(uuidNotificationEvent);
    final response = await _invoke({
      'mode': 'preview',
      'uuid_notification_event': cleanUuid,
    });
    return ManualNotificationAudiencePreview.fromJson(
      _responseJson(response.data),
      expectedEventUuid: cleanUuid,
    );
  }

  Future<ManualNotificationDispatchAcceptance> requestManualDispatch(
    String uuidNotificationEvent, {
    String? requestId,
    String? retryDispatchUuid,
  }) async {
    final cleanEventUuid = _requiredEventUuid(uuidNotificationEvent);
    final response = await _invoke({
      'mode': 'send',
      'uuid_notification_event': cleanEventUuid,
      'request_id': _requestId(requestId),
      if (retryDispatchUuid != null)
        'retry_dispatch_uuid': _requiredDispatchUuid(retryDispatchUuid),
    });
    return ManualNotificationDispatchAcceptance.fromJson(
      _responseJson(response.data),
      expectedEventUuid: cleanEventUuid,
    );
  }

  Future<ManualNotificationDispatchAcceptance> requestManualResend(
    String uuidNotificationEvent,
    String sourceDispatchUuid, {
    String? requestId,
  }) async {
    final cleanEventUuid = _requiredEventUuid(uuidNotificationEvent);
    final response = await _invoke({
      'mode': 'send',
      'uuid_notification_event': cleanEventUuid,
      'request_id': _requestId(requestId),
      'source_dispatch_uuid': _requiredDispatchUuid(sourceDispatchUuid),
    });
    final acceptance = ManualNotificationDispatchAcceptance.fromJson(
      _responseJson(response.data),
      expectedEventUuid: cleanEventUuid,
    );
    if (acceptance.sourceDispatchUuid != sourceDispatchUuid.trim()) {
      throw const FormatException(
        'La respuesta de reenvío de notificaciones es inválida.',
      );
    }
    return acceptance;
  }

  Future<NotificationDispatchAnalytics> loadAnalytics(
    String uuidNotificationDispatch,
  ) async {
    final cleanUuid = _requiredDispatchUuid(uuidNotificationDispatch);
    final response = await _invoke({
      'mode': 'analytics',
      'uuid_notification_dispatch': cleanUuid,
    });
    return NotificationDispatchAnalytics.fromJson(
      _responseJson(response.data),
      expectedDispatchUuid: cleanUuid,
    );
  }

  String _requiredEventUuid(String value) {
    final clean = value.trim();
    if (clean.isEmpty) {
      throw ArgumentError.value(
        value,
        'uuidNotificationEvent',
        'El identificador del evento no puede estar vac\u00edo.',
      );
    }
    return clean;
  }

  String _requiredDispatchUuid(String value) {
    final clean = value.trim();
    if (clean.isEmpty) {
      throw ArgumentError.value(
        value,
        'uuidNotificationDispatch',
        'El identificador del envío no puede estar vacío.',
      );
    }
    return clean;
  }

  String _requestId(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? _generateUuidV4() : clean;
  }

  Future<FunctionResponse> _invoke(Map<String, dynamic> body) async {
    if (_supabase.auth.currentSession?.isExpired ?? false) {
      await _refreshSessionOrThrow();
    }

    try {
      return await _supabase.functions.invoke(_functionName, body: body);
    } on FunctionException catch (error) {
      if (!_isInvalidJwt(error)) {
        rethrow;
      }

      await _refreshSessionOrThrow();
      return _supabase.functions.invoke(_functionName, body: body);
    }
  }

  Future<void> _refreshSessionOrThrow() async {
    try {
      await _refreshSession();
    } catch (_) {
      throw StateError(
        'La sesión de Supabase expiró. Cierra sesión y vuelve a iniciar sesión.',
      );
    }
  }

  bool _isInvalidJwt(FunctionException error) {
    if (error.status != 401) {
      return false;
    }

    final details = error.details;
    if (details is Map) {
      final nestedError = details['error'];
      if (nestedError is Map) {
        final nestedMessage = nestedError['message'];
        if (nestedMessage is String &&
            nestedMessage.toLowerCase().contains('jwt')) {
          return true;
        }
      }

      final message = details['message'];
      if (message is String && message.toLowerCase().contains('jwt')) {
        return true;
      }
    }

    return error.toString().toLowerCase().contains('jwt');
  }

  Map<String, dynamic> _responseJson(Object? data) {
    if (data is Map) {
      final json = Map<String, dynamic>.from(data);
      final error = json['error'];
      if (error != null) {
        throw StateError(_errorMessage(error));
      }
      return json;
    }
    throw const FormatException(
      'La respuesta de notificaciones es inv\u00e1lida.',
    );
  }

  String _errorMessage(Object error) {
    if (error is Map) {
      final message = error['message'] ?? error['error'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }
    }
    final message = error.toString().trim();
    return message.isEmpty ? 'Error remoto de notificaciones.' : message;
  }
}

String _generateUuidV4() {
  final random = math.Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hexByte(int value) => value.toRadixString(16).padLeft(2, '0');
  final hex = bytes.map(hexByte).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}
