import 'dart:async';
import 'dart:convert';

import 'package:app_api_client/app_api_client.dart' show RealtimeApi;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/sessions/data/chat_presence_service_impl.dart';
import 'package:coriolis_companion/shared/config/app_config.dart';

// ---------------------------------------------------------------------------
// Mocks / fakes
// ---------------------------------------------------------------------------

class _MockRealtimeApi extends Mock implements RealtimeApi {}

AppConfig _fakeConfig() => const AppConfig(
      apiBaseUrl: 'http://localhost:3010/api/v1',
      authBaseUrl: 'http://localhost:3010',
      realtimeWsUrl: 'ws://localhost:8000/connection/websocket',
    );

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds the JWT `connInfo` bytes for a single membership entry.
List<int> _connInfo(String gameSessionId, String membershipId) {
  return utf8.encode(jsonEncode({
    'memberships': [
      {'gameSessionId': gameSessionId, 'membershipId': membershipId},
    ],
  }));
}

/// Builds connInfo with memberships for two different sessions.
List<int> _connInfoMultiSession(
  String gsId1,
  String memberId1,
  String gsId2,
  String memberId2,
) {
  return utf8.encode(jsonEncode({
    'memberships': [
      {'gameSessionId': gsId1, 'membershipId': memberId1},
      {'gameSessionId': gsId2, 'membershipId': memberId2},
    ],
  }));
}

// ---------------------------------------------------------------------------
// _InstrumentedPresenceService — drives the internal state machine directly
// without a real Centrifugo connection so we can test stream emissions.
// ---------------------------------------------------------------------------

class _InstrumentedPresenceService extends ChatPresenceServiceImpl {
  _InstrumentedPresenceService()
      : super(
          realtimeApi: _MockRealtimeApi(),
          config: _fakeConfig(),
        );

  void simulateSnapshot(
    Map<String, List<int>> clientConnInfoMap,
    String gameSessionId,
  ) {
    clientToMembership.clear();
    for (final entry in clientConnInfoMap.entries) {
      final id = membershipIdFromConnInfo(entry.value, gameSessionId);
      if (id != null) clientToMembership[entry.key] = id;
    }
    emitSnapshot();
  }

  void simulateJoin(
    String clientId,
    List<int> connInfo,
    String gameSessionId,
  ) {
    final id = membershipIdFromConnInfo(connInfo, gameSessionId);
    if (id != null) clientToMembership[clientId] = id;
    emitSnapshot();
  }

  void simulateLeave(String clientId) {
    clientToMembership.remove(clientId);
    emitSnapshot();
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ChatPresenceServiceImpl — membershipIdFromConnInfo', () {
    late _InstrumentedPresenceService service;

    setUp(() => service = _InstrumentedPresenceService());
    tearDown(() async => service.dispose());

    test('decodes matching entry', () {
      final bytes = _connInfo('gs-1', 'm-abc');
      expect(service.membershipIdFromConnInfo(bytes, 'gs-1'), 'm-abc');
    });

    test('returns null when gameSessionId does not match', () {
      final bytes = _connInfo('gs-1', 'm-abc');
      expect(service.membershipIdFromConnInfo(bytes, 'gs-999'), isNull);
    });

    test('finds the matching entry among multiple memberships', () {
      final bytes = _connInfoMultiSession('gs-1', 'm-a', 'gs-2', 'm-b');
      expect(service.membershipIdFromConnInfo(bytes, 'gs-2'), 'm-b');
    });

    test('returns null for null connInfo', () {
      expect(service.membershipIdFromConnInfo(null, 'gs-1'), isNull);
    });

    test('returns null for empty connInfo bytes', () {
      expect(service.membershipIdFromConnInfo(const [], 'gs-1'), isNull);
    });

    test('silently skips invalid JSON bytes', () {
      final bad = utf8.encode('not-json');
      expect(service.membershipIdFromConnInfo(bad, 'gs-1'), isNull);
    });

    test('silently skips when memberships key is missing', () {
      final bytes = utf8.encode(jsonEncode({'other': 'value'}));
      expect(service.membershipIdFromConnInfo(bytes, 'gs-1'), isNull);
    });

    test('silently skips when memberships is not a list', () {
      final bytes = utf8.encode(jsonEncode({'memberships': 'string'}));
      expect(service.membershipIdFromConnInfo(bytes, 'gs-1'), isNull);
    });

    test('skips malformed list entries and still returns valid one', () {
      final bytes = utf8.encode(jsonEncode({
        'memberships': [
          'bad-entry',
          {'gameSessionId': 'gs-1', 'membershipId': 'm-good'},
        ],
      }));
      expect(service.membershipIdFromConnInfo(bytes, 'gs-1'), 'm-good');
    });

    test('returns null when gameSessionId param is null', () {
      final bytes = _connInfo('gs-1', 'm-abc');
      expect(service.membershipIdFromConnInfo(bytes, null), isNull);
    });
  });

  group('ChatPresenceServiceImpl — stream behaviour', () {
    // The broadcast StreamController uses async delivery (microtask queue).
    // We await a microtask flush after each emit so the listener fires.
    Future<void> pump() => Future<void>.delayed(Duration.zero);

    test('initial snapshot emits correct online set filtered by session',
        () async {
      final service = _InstrumentedPresenceService();
      final emitted = <Set<String>>[];
      final sub = service.onlineIds.listen(emitted.add);

      service.simulateSnapshot({
        'c1': _connInfo('gs-1', 'm-alice'),
        'c2': _connInfo('gs-1', 'm-bob'),
        'c3': _connInfo('gs-2', 'm-charlie'), // different session — filtered
      }, 'gs-1');
      await pump();

      expect(emitted.last, {'m-alice', 'm-bob'});

      await sub.cancel();
      await service.dispose();
    });

    test('join event adds membershipId to online set', () async {
      final service = _InstrumentedPresenceService();
      final emitted = <Set<String>>[];
      final sub = service.onlineIds.listen(emitted.add);

      service.simulateSnapshot({'c1': _connInfo('gs-1', 'm-alice')}, 'gs-1');
      await pump();
      service.simulateJoin('c2', _connInfo('gs-1', 'm-bob'), 'gs-1');
      await pump();

      expect(emitted.last, {'m-alice', 'm-bob'});

      await sub.cancel();
      await service.dispose();
    });

    test('leave event removes client but keeps membershipId if another client '
        'for same membership is still present', () async {
      final service = _InstrumentedPresenceService();
      final emitted = <Set<String>>[];
      final sub = service.onlineIds.listen(emitted.add);

      // Two clients for m-alice (phone + laptop scenario).
      service.simulateSnapshot({
        'c1': _connInfo('gs-1', 'm-alice'),
        'c2': _connInfo('gs-1', 'm-alice'),
      }, 'gs-1');
      await pump();
      expect(emitted.last, {'m-alice'});

      // c1 leaves — c2 still holds m-alice.
      service.simulateLeave('c1');
      await pump();
      expect(emitted.last, {'m-alice'});

      // c2 also leaves — now offline.
      service.simulateLeave('c2');
      await pump();
      expect(emitted.last, isEmpty);

      await sub.cancel();
      await service.dispose();
    });

    test('malformed connInfo bytes in snapshot are silently skipped', () async {
      final service = _InstrumentedPresenceService();
      final emitted = <Set<String>>[];
      final sub = service.onlineIds.listen(emitted.add);

      service.simulateSnapshot({
        'c1': utf8.encode('not-json'),          // malformed
        'c2': _connInfo('gs-1', 'm-valid'),      // valid
        'c3': utf8.encode(jsonEncode({'x': 1})), // wrong shape
      }, 'gs-1');
      await pump();

      expect(emitted.last, {'m-valid'});

      await sub.cancel();
      await service.dispose();
    });

    test('dispose closes the onlineIds stream', () async {
      final service = _InstrumentedPresenceService();
      bool done = false;
      service.onlineIds.listen(null, onDone: () => done = true);
      await service.dispose();
      await pump();
      expect(done, isTrue);
    });
  });
}
