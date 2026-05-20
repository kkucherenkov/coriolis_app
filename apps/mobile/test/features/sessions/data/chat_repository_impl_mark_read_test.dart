import 'package:app_api_client/app_api_client.dart'
    show ChatApi, GameSessionsApi, MarkReadRequest;
import 'package:dio/dio.dart' show Response, RequestOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/sessions/data/chat_repository_impl.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class _MockChatApi extends Mock implements ChatApi {}

class _MockGameSessionsApi extends Mock implements GameSessionsApi {}

// ── Helpers ───────────────────────────────────────────────────────────────────

Response<void> _voidResponse() => Response<void>(
      data: null,
      statusCode: 200,
      requestOptions: RequestOptions(),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _MockChatApi chatApi;
  late _MockGameSessionsApi gameSessionsApi;
  late ChatRepositoryImpl repo;

  setUp(() {
    chatApi = _MockChatApi();
    gameSessionsApi = _MockGameSessionsApi();
    repo = ChatRepositoryImpl(
      chatApi: chatApi,
      gameSessionsApi: gameSessionsApi,
    );

    // Register fallback value required by mocktail for MarkReadRequest.
    registerFallbackValue(MarkReadRequest((b) => b
      ..lastReadAt = DateTime.utc(2026, 1, 1)));
  });

  group('ChatRepositoryImpl.markRead', () {
    test(
      'sends MarkReadRequest.lastReadAt equal to the provided lastReadAt, '
      'not DateTime.now()',
      () async {
        final messageCreatedAt = DateTime.utc(2026, 5, 16, 10, 30, 0);

        when(
          () => gameSessionsApi.markChatConversationRead(
            id: any(named: 'id'),
            conversationKey: any(named: 'conversationKey'),
            markReadRequest: any(named: 'markReadRequest'),
          ),
        ).thenAnswer((_) async => _voidResponse());

        await repo.markRead(
          'gs-1',
          conversation: 'broadcast',
          lastReadMessageId: 'm-42',
          lastReadAt: messageCreatedAt,
        );

        final captured = verify(
          () => gameSessionsApi.markChatConversationRead(
            id: 'gs-1',
            conversationKey: 'broadcast',
            markReadRequest: captureAny(named: 'markReadRequest'),
          ),
        ).captured;

        expect(captured, hasLength(1));
        final req = captured.single as MarkReadRequest;
        expect(
          req.lastReadAt,
          messageCreatedAt.toUtc(),
          reason: 'lastReadAt must be the caller-provided message createdAt, '
              'not wall-clock now',
        );
      },
    );

    test(
      'converts a local-time lastReadAt to UTC before sending',
      () async {
        // Simulate a DateTime that is NOT in UTC (e.g. from a timezone offset).
        final localTime = DateTime(2026, 5, 16, 12, 0, 0); // local time

        when(
          () => gameSessionsApi.markChatConversationRead(
            id: any(named: 'id'),
            conversationKey: any(named: 'conversationKey'),
            markReadRequest: any(named: 'markReadRequest'),
          ),
        ).thenAnswer((_) async => _voidResponse());

        await repo.markRead(
          'gs-1',
          conversation: 'broadcast',
          lastReadMessageId: 'm-43',
          lastReadAt: localTime,
        );

        final captured = verify(
          () => gameSessionsApi.markChatConversationRead(
            id: any(named: 'id'),
            conversationKey: any(named: 'conversationKey'),
            markReadRequest: captureAny(named: 'markReadRequest'),
          ),
        ).captured;

        final req = captured.single as MarkReadRequest;
        expect(
          req.lastReadAt.isUtc,
          isTrue,
          reason: 'lastReadAt sent to API must always be UTC',
        );
        expect(
          req.lastReadAt,
          localTime.toUtc(),
        );
      },
    );
  });
}
