import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/characters/data/cached_character_repository.dart';
import 'package:coriolis_companion/features/characters/data/character_api_mapper.dart';
import 'package:coriolis_companion/features/characters/data/character_cache.dart';
import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/features/characters/domain/character_summary.dart';

class _MockRemote extends Mock implements CharacterRepository {}

class _MockCache extends Mock implements LocalCharacterCache {}

api_client.Character _wire({
  String id = 'char-1',
  String name = 'Tael',
  api_client.CharacterStatusEnum status =
      api_client.CharacterStatusEnum.draft,
}) =>
    api_client.Character((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..upbringing = api_client.Upbringing.plebeian
      ..reputation = 0
      ..startingWealth = 0
      ..birr = 0
      ..mutant = false
      ..status = status
      ..attributes.replace(api_client.Attributes((a) => a
        ..strength = 3
        ..agility = 3
        ..wits = 3
        ..empathy = 3))
      ..skills.replace(api_client.Skills((s) => s
        ..dexterity = 0
        ..force = 0
        ..infiltration = 0
        ..manipulation = 0
        ..meleeCombat = 0
        ..observation = 0
        ..rangedCombat = 0
        ..survival = 0
        ..command = 0
        ..culture = 0
        ..dataDjinn = 0
        ..medicurgy = 0
        ..mysticPowers = 0
        ..pilot = 0
        ..science = 0
        ..technology = 0))
      ..hp.replace(api_client.CharacterHp((h) => h
        ..current = 5
        ..max = 5))
      ..mp.replace(api_client.CharacterMp((m) => m
        ..current = 5
        ..max = 5))
      ..encumbrance.replace(api_client.CharacterEncumbrance((e) => e
        ..current = 0
        ..max = 10))
      ..experience = 0
      ..conditions.replace(api_client.ConditionFlags((c) => c
        ..exhausted = false
        ..sleepless = false
        ..thirsty = false
        ..hungry = false))
      ..criticalInjuries.replace(BuiltList<api_client.CriticalInjury>())
      ..talents.replace(BuiltList<api_client.Talent>())
      ..relationships.replace(BuiltList<api_client.Relationship>())
      ..inventory.replace(BuiltList<api_client.Item>())
      ..updatedAt = DateTime.utc(2026, 5, 16)
      ..createdAt = DateTime.utc(2026, 5, 16));

void main() {
  late _MockRemote remote;
  late _MockCache cache;
  late CachedCharacterRepository sut;

  setUp(() {
    remote = _MockRemote();
    cache = _MockCache();
    sut = CachedCharacterRepository(remote: remote, cache: cache);
    registerFallbackValue(_wire());
  });

  group('list', () {
    test('returns remote summaries on success', () async {
      when(() => remote.list(limit: 20)).thenAnswer(
        (_) async => [
          const CharacterSummary(id: 'char-1', name: 'Tael', concept: null),
        ],
      );

      final summaries = await sut.list();

      expect(summaries.single.id, 'char-1');
      verifyNever(() => cache.readAll());
      verifyNever(() => cache.write(any()));
    });

    test('falls back to cache.readAll on network DioException', () async {
      when(() => remote.list(limit: 20)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/characters'),
          type: DioExceptionType.connectionError,
        ),
      );
      when(() => cache.readAll()).thenAnswer((_) async => [_wire()]);

      final summaries = await sut.list();

      expect(summaries.single.id, 'char-1');
      expect(summaries.single.name, 'Tael');
    });

    test('rethrows non-network DioException', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/characters'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/characters'),
          statusCode: 500,
        ),
      );
      when(() => remote.list(limit: 20)).thenThrow(err);

      expect(() => sut.list(), throwsA(same(err)));
      verifyNever(() => cache.readAll());
    });
  });

  group('get', () {
    test('returns remote result on success and does NOT touch cache', () async {
      final domain = CharacterApiMapper.toDomain(_wire());
      when(() => remote.get('char-1')).thenAnswer((_) async => domain);

      final got = await sut.get('char-1');

      expect(got.id, 'char-1');
      verifyNever(() => cache.write(any()));
      verifyNever(() => cache.read(any()));
    });

    test('falls back to cache when remote throws network DioException',
        () async {
      when(() => remote.get('char-1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/characters/char-1'),
          type: DioExceptionType.connectionError,
        ),
      );
      when(() => cache.read('char-1')).thenAnswer((_) async => _wire());

      final got = await sut.get('char-1');

      expect(got.id, 'char-1');
    });

    test('rethrows when remote network fails AND cache miss', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/characters/char-1'),
        type: DioExceptionType.connectionError,
      );
      when(() => remote.get('char-1')).thenThrow(err);
      when(() => cache.read('char-1')).thenAnswer((_) async => null);

      expect(() => sut.get('char-1'), throwsA(same(err)));
    });

    test('rethrows non-network DioException without touching cache', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/characters/char-1'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/characters/char-1'),
          statusCode: 404,
        ),
      );
      when(() => remote.get('char-1')).thenThrow(err);

      expect(() => sut.get('char-1'), throwsA(same(err)));
      verifyNever(() => cache.read(any()));
    });
  });

  group('mutations invalidate cache on success', () {
    test('update delegates to remote and clears cached row', () async {
      final domain = CharacterApiMapper.toDomain(_wire(name: 'X'));
      when(() => remote.update('char-1', name: 'X'))
          .thenAnswer((_) async => domain);
      when(() => cache.delete('char-1')).thenAnswer((_) async {});

      final updated = await sut.update('char-1', name: 'X');

      expect(updated.name, 'X');
      verify(() => remote.update('char-1', name: 'X')).called(1);
      verify(() => cache.delete('char-1')).called(1);
    });

    test('delete delegates to remote and clears cached row', () async {
      when(() => remote.delete('char-1')).thenAnswer((_) async {});
      when(() => cache.delete('char-1')).thenAnswer((_) async {});

      await sut.delete('char-1');

      verify(() => remote.delete('char-1')).called(1);
      verify(() => cache.delete('char-1')).called(1);
    });

    test('mutation failure does NOT clear the cache', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/characters/char-1'),
        type: DioExceptionType.connectionError,
      );
      when(() => remote.delete('char-1')).thenThrow(err);

      expect(() => sut.delete('char-1'), throwsA(same(err)));
      verifyNever(() => cache.delete(any()));
    });
  });
}
