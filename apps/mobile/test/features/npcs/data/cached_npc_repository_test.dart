import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/npcs/data/cached_npc_repository.dart';
import 'package:coriolis_companion/features/npcs/data/npc_cache.dart';
import 'package:coriolis_companion/features/npcs/domain/npc_repository.dart';
import 'package:coriolis_companion/features/npcs/domain/npc_summary.dart';

class _MockRemote extends Mock implements NpcRepository {}

class _MockCache extends Mock implements LocalNpcCache {}

api_client.Npc _wireNpc({
  String id = 'npc-1',
  String name = 'Syndicate Guard',
}) =>
    api_client.Npc((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..updatedAt = DateTime.utc(2026, 5, 17)
      ..createdAt = DateTime.utc(2026, 5, 17)
      ..attributes.update((ab) => ab
        ..strength = 3
        ..agility = 3
        ..wits = 2
        ..empathy = 2)
      ..skills.update((sb) => sb
        ..dexterity = 0
        ..force = 1
        ..infiltration = 0
        ..manipulation = 0
        ..meleeCombat = 1
        ..observation = 0
        ..rangedCombat = 2
        ..survival = 0
        ..command = 0
        ..culture = 0
        ..dataDjinn = 0
        ..medicurgy = 0
        ..mysticPowers = 0
        ..pilot = 0
        ..science = 0
        ..technology = 0)
      ..hp.update((hb) => hb
        ..current = 6
        ..max = 6)
      ..mp.update((mb) => mb
        ..current = 4
        ..max = 4)
      ..armor.replace(BuiltList<api_client.ItemArmor>())
      ..weapons.replace(BuiltList<api_client.ItemWeapon>())
      ..tags.replace(BuiltList<String>()));

NpcSummary _domain({String id = 'npc-1', String name = 'Syndicate Guard'}) =>
    NpcSummary(id: id, name: name);

DioException _networkError(DioExceptionType type) => DioException(
      requestOptions: RequestOptions(path: '/npcs'),
      type: type,
    );

DioException _badResponse(int status) => DioException(
      requestOptions: RequestOptions(path: '/npcs'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/npcs'),
        statusCode: status,
      ),
    );

void main() {
  late _MockRemote remote;
  late _MockCache cache;
  late CachedNpcRepository sut;

  setUp(() {
    remote = _MockRemote();
    cache = _MockCache();
    sut = CachedNpcRepository(remote: remote, cache: cache);
    registerFallbackValue(_wireNpc());
    registerFallbackValue(_domain());
  });

  group('list', () {
    test('happy path — returns remote list, cache not touched', () async {
      final summaries = [_domain()];
      when(() => remote.list(limit: 20)).thenAnswer((_) async => summaries);

      final result = await sut.list();

      expect(result, equals(summaries));
      verifyNever(() => cache.readAll());
      verifyNever(() => cache.write(any()));
    });

    test('connectionError → cache hit → returns mapped list', () async {
      when(() => remote.list(limit: 20))
          .thenThrow(_networkError(DioExceptionType.connectionError));
      when(() => cache.readAll()).thenAnswer((_) async => [
            _wireNpc(id: 'npc-1', name: 'Alpha'),
            _wireNpc(id: 'npc-2', name: 'Beta'),
            _wireNpc(id: 'npc-3', name: 'Gamma'),
          ]);

      final result = await sut.list();

      expect(result.length, 3);
      expect(result.map((n) => n.id), containsAll(['npc-1', 'npc-2', 'npc-3']));
    });

    test('connectionTimeout → empty cache → returns [], does not rethrow',
        () async {
      when(() => remote.list(limit: 20))
          .thenThrow(_networkError(DioExceptionType.connectionTimeout));
      when(() => cache.readAll()).thenAnswer((_) async => []);

      final result = await sut.list();

      expect(result, isEmpty);
    });

    test('badResponse (4xx) → propagates, cache untouched', () async {
      final err = _badResponse(403);
      when(() => remote.list(limit: 20)).thenThrow(err);

      expect(() => sut.list(), throwsA(same(err)));
      verifyNever(() => cache.readAll());
    });

    test('list(limit: 50) happy path → remote called with limit: 50', () async {
      when(() => remote.list(limit: 50)).thenAnswer((_) async => [_domain()]);

      await sut.list(limit: 50);

      verify(() => remote.list(limit: 50)).called(1);
    });
  });
}
