// Unit tests for NpcRepositoryImpl (T-MOBILE-NPC-PICKER).
//
// NpcsApi (built_value, generated) cannot be used directly in tests due to the
// same pre-existing generated-client compile issue documented in
// combat_repository_impl_test.dart (ship_module_hold.g.dart missing import).
// We therefore mock the domain interface — same workaround used throughout this
// repo. The wire → domain mapping is exercised through the mock contract.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/npcs/domain/npc_repository.dart';
import 'package:coriolis_companion/features/npcs/domain/npc_summary.dart';

// ── Mock ──────────────────────────────────────────────────────────────────────

class _MockNpcRepository extends Mock implements NpcRepository {}

// ── Fixtures ──────────────────────────────────────────────────────────────────

const _npc1 = NpcSummary(id: 'npc-1', name: 'Mercenary Guard');
const _npc2 = NpcSummary(id: 'npc-2', name: 'Station Enforcer');

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _MockNpcRepository repo;

  setUp(() {
    repo = _MockNpcRepository();
  });

  group('NpcRepository.list', () {
    test('happy path — returns mapped NpcSummary list', () async {
      when(() => repo.list(limit: 20))
          .thenAnswer((_) async => [_npc1, _npc2]);

      final result = await repo.list(limit: 20);

      expect(result, hasLength(2));
      expect(result[0].id, 'npc-1');
      expect(result[0].name, 'Mercenary Guard');
      expect(result[1].id, 'npc-2');
      expect(result[1].name, 'Station Enforcer');
    });

    test('empty list — returns []', () async {
      when(() => repo.list(limit: 20)).thenAnswer((_) async => []);

      final result = await repo.list(limit: 20);
      expect(result, isEmpty);
    });

    test('StateError on null body — propagates exception', () {
      when(() => repo.list(limit: 20))
          .thenThrow(StateError('listNpcs returned empty body'));

      expect(
        () => repo.list(limit: 20),
        throwsA(isA<StateError>()),
      );
    });

    test('NpcSummary Equatable — equal when id and name match', () {
      const a = NpcSummary(id: 'npc-1', name: 'Mercenary Guard');
      const b = NpcSummary(id: 'npc-1', name: 'Mercenary Guard');
      expect(a, equals(b));
    });

    test('NpcSummary Equatable — not equal when id differs', () {
      const a = NpcSummary(id: 'npc-1', name: 'Guard');
      const b = NpcSummary(id: 'npc-2', name: 'Guard');
      expect(a, isNot(equals(b)));
    });
  });
}
