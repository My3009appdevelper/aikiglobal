import 'package:aikiglobal/core/notifications/notification_message.dart';
import 'package:aikiglobal/core/notifications/notification_payload_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationPayloadCodec', () {
    test('decodes schema version 1 and preserves notification text', () {
      const message = NotificationMessage(
        data: {
          'schema_version': '1',
          'uuid_notification_dispatch': _dispatchUuid,
          'uuid_notification_inbox': _inboxUuid,
          'category': 'content',
          'action_type': 'open_content_item',
          'action_payload': '{"uuid_content_item":"$_contentUuid"}',
        },
        title: '  Título AIKI  ',
        body: 'Mensaje con acentos y ñ.',
      );

      final payload = const NotificationPayloadCodec().tryDecode(message);

      expect(payload, isNotNull);
      expect(payload!.schemaVersion, '1');
      expect(payload.uuidNotificationDispatch, _dispatchUuid);
      expect(payload.uuidNotificationInbox, _inboxUuid);
      expect(payload.category, 'content');
      expect(payload.actionType, 'open_content_item');
      expect(payload.actionPayload, {'uuid_content_item': _contentUuid});
      expect(payload.title, '  Título AIKI  ');
      expect(payload.body, 'Mensaje con acentos y ñ.');
    });

    test('rejects unsupported schemas', () {
      final payload = const NotificationPayloadCodec().tryDecode(
        _message(dataOverrides: const {'schema_version': '2'}),
      );

      expect(payload, isNull);
    });

    test('rejects missing required identifiers', () {
      final payload = const NotificationPayloadCodec().tryDecode(
        _message(dataOverrides: const {'uuid_notification_inbox': '  '}),
      );

      expect(payload, isNull);
    });

    test('rejects non-string data values', () {
      final payload = const NotificationPayloadCodec().tryDecode(
        _message(dataOverrides: const {'category': 1}),
      );

      expect(payload, isNull);
    });

    test('rejects unknown categories and actions', () {
      final codec = const NotificationPayloadCodec();

      expect(
        codec.tryDecode(_message(dataOverrides: const {'category': 'unknown'})),
        isNull,
      );
      expect(
        codec.tryDecode(
          _message(dataOverrides: const {'action_type': 'open_unknown'}),
        ),
        isNull,
      );
    });

    test('rejects malformed or non-object action payload JSON', () {
      final codec = const NotificationPayloadCodec();

      expect(
        codec.tryDecode(
          _message(dataOverrides: const {'action_payload': '{malformed'}),
        ),
        isNull,
      );
      expect(
        codec.tryDecode(
          _message(dataOverrides: const {'action_payload': '["value"]'}),
        ),
        isNull,
      );
    });

    test('requires a content UUID for open_content_item', () {
      final payload = const NotificationPayloadCodec().tryDecode(
        _message(
          dataOverrides: const {
            'action_type': 'open_content_item',
            'action_payload': '{}',
          },
        ),
      );

      expect(payload, isNull);
    });

    test('rejects malformed notification and content UUIDs', () {
      final codec = const NotificationPayloadCodec();

      expect(
        codec.tryDecode(
          _message(
            dataOverrides: const {'uuid_notification_dispatch': 'dispatch-1'},
          ),
        ),
        isNull,
      );
      expect(
        codec.tryDecode(
          _message(
            dataOverrides: const {
              'action_type': 'open_content_item',
              'action_payload': '{"uuid_content_item":"content-1"}',
            },
          ),
        ),
        isNull,
      );
    });
  });
}

NotificationMessage _message({Map<String, Object?> dataOverrides = const {}}) {
  return NotificationMessage(
    data: {
      'schema_version': '1',
      'uuid_notification_dispatch': _dispatchUuid,
      'uuid_notification_inbox': _inboxUuid,
      'category': 'general',
      'action_type': 'none',
      'action_payload': '{}',
      ...dataOverrides,
    },
    title: 'Aviso',
    body: 'Mensaje',
  );
}

const _dispatchUuid = '11111111-1111-4111-8111-111111111111';
const _inboxUuid = '22222222-2222-4222-8222-222222222222';
const _contentUuid = '33333333-3333-4333-8333-333333333333';
